//
//  FirebaseViewModel.swift
//  SnapPlan
//
//  Created by opfic on 12/30/24.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class FirebaseViewModel: ObservableObject {
    private var userId: String? { Auth.auth().currentUser?.uid }
    private let db = Firestore.firestore()
    var email: String { Auth.auth().currentUser?.email ?? "" }  //  뷰에서 변경하지 않아서 published로 하지 않음
    @Published var signedIn: Bool? = nil
    @Published var is12TimeFmt: Bool = true
    @Published var screenMode: UIUserInterfaceStyle = .unspecified
    @Published var schedules: [String:ScheduleData] = [:]
    
    init() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error as NSError?, error.code == -4 {    // -4: 로그인 세션이 만료된 경우
                self.signedIn = false
            }
            else if let error = error {
                print("Last Login Restore Error: \(error.localizedDescription)")
                return
            }

            if let _ = user {
                Task {
                    await self.loadTimeFormat()
                    await self.loadScreenMode()
                    self.signedIn = true
                }
            }
        }
    }
    
    /// 사용자의 12시간제 포맷을 불러오는 메소드
    private func loadTimeFormat() async {
        do {
            if let value = try await fetch12TimeFmt() {
                await MainActor.run {
                    self.is12TimeFmt = value
                }
            }
        } catch {
            print("TimeFormat Load Error: \(error.localizedDescription)")
        }
    }
    
    /// 스크린 모드를 불러오는 메소드
    private func loadScreenMode() async {
        do {
            if let value = try await fetchScreenMode() {
                await MainActor.run {
                    self.screenMode = UIUserInterfaceStyle(rawValue: value)
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        windowScene.windows.first?.overrideUserInterfaceStyle = self.screenMode
                    }
                }
            }
        } catch {
            print("ScreenMode Load Error: \(error.localizedDescription)")
        }
    }
    
    /// 사용자의 오늘을 포함한 달의 전체 스케줄 데이터를 불러오는 메소드
    func loadScheduleData(date: Date = Date()) async {
        do {
            if let dict = try await fetchScheduleData(date: date) {
                await MainActor.run {
                    self.schedules.merge(dict) { _, new in new }
                }
            }
        } catch {
            print("Schedule Load Error: \(error.localizedDescription)")
        }
    }
}

// MARK: - 12/24시간제 포맷 관련 기능
extension FirebaseViewModel {
    func set12TimeFmt(timeFmt: Bool) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("info")
        
        do {
            try await docRef.setData(["is12TimeFmt": timeFmt], merge: true)
        } catch {
            throw error
        }
    }
    
    func fetch12TimeFmt() async throws -> Bool? {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("info")
        
        do {
            let document = try await docRef.getDocument()
            let timeFmt = document.data()?["is12TimeFmt"] as? Bool
            return timeFmt
        } catch {
            throw error
        }
    }
}

// MARK: - 사용자 관련 기능
extension FirebaseViewModel {
    /// Firebase에 사용자 정보를 저장하는 메소드
    private func saveUserToFirestore(user: User) {
        let userRef = db.collection(user.uid).document("info")
        let userInfo: [String: Any] = [
            "uid": user.uid,    //  uid
            "email": user.email ?? "",  //  이메일
            "name": user.displayName ?? "",  //  이름
            "signedAt": FieldValue.serverTimestamp(),   //  가입 시간
            "is12TimeFmt": true,    //  12시간제 포맷 여부
            "screenMode": "unspecified"    //  화면 모드
        ]
        
        userRef.setData(userInfo, merge: true) { error in
            if let error = error {
                print("Error saving user: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        let batch = db.batch()
        let docs = try await db.collection(user.uid).getDocuments()
        for doc in docs.documents {
            batch.deleteDocument(doc.reference)
        }
        try await batch.commit()
        await signOutGoogle()
        try await user.delete()
    }
}

// MARK: - 테마 관련 기능
extension FirebaseViewModel {
    func setScreenMode(mode: UIUserInterfaceStyle) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("info")
        
        do {
            try await docRef.setData(["screenMode": mode.rawValue], merge: true)
        } catch {
            throw error
        }
    }
    
    func fetchScreenMode() async throws -> String? {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("info")
        
        do {
            let document = try await docRef.getDocument()
            let screenMode = document.data()?["screenMode"] as? String ?? "unspecified"
            return screenMode
        } catch {
            throw error
        }
    }

}

// MARK: - 스케줄 관련 기능
extension FirebaseViewModel {
    func addScheduleData(schedule: ScheduleData) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }

        let docRef = db.collection(userId).document("schedules").collection("data").document(schedule.id.uuidString)
        
        do {
            let newEntry: [String: Any] = [
                "title": schedule.title,
                "startDate": schedule.startDate,
                "endDate": schedule.endDate,
                "allDay": schedule.allDay,
                "cycleOption": schedule.cycleOption.rawValue,
                "location": schedule.location,
                "address": schedule.address,
                "description": schedule.description,
                "color": schedule.color
            ]
            
            try await docRef.setData(newEntry, merge: true)
        } catch {
            throw error
        }
    }
    
    func deleteScheduleData(schedule: ScheduleData) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        do {
            try await db.collection(userId).document("schedules").collection("data").document(schedule.id.uuidString).delete()
            schedules.removeValue(forKey: schedule.id.uuidString)
        } catch {
            print("Schedule Delete Error: \(error.localizedDescription)")
        }
    }
    
    func modifyScheduleData(schedule: ScheduleData) async throws {
        guard let _ = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        do {
//            try await deleteScheduleData(schedule: schedule)
            try await addScheduleData(schedule: schedule)
        } catch {
            print("Schedule Modify Error: \(error.localizedDescription)")
        }
    }

    
    func fetchScheduleData(date: Date) async throws -> [String:ScheduleData]? {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        var dict: [String: ScheduleData] = [:]
        
        let startOfDay = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)!

        let dbRef = db.collection(userId).document("schedules").collection("data")
        
        async let snapshot1 = dbRef
            .whereField("startDate", isLessThanOrEqualTo: endOfDay)
            .whereField("endDate", isGreaterThanOrEqualTo: startOfDay)
            .getDocuments()
        
        async let snapshot2 = dbRef
            .whereField("cycleOption", isNotEqualTo: "none")
            .getDocuments()

        let (result1, result2) = try await (snapshot1, snapshot2)

        var seenDocumentIDs: Set<String> = Set()

        let schedules: [ScheduleData] = (result1.documents + result2.documents).compactMap { document in
            let documentIdString = document.documentID
            guard !seenDocumentIDs.contains(documentIdString) else {
                return nil
            }
            seenDocumentIDs.insert(documentIdString)

            let data = document.data()
            
            guard let title = data["title"] as? String,
                  let startDate = data["startDate"] as? Timestamp,
                  let endDate = data["endDate"] as? Timestamp,
                  let color = data["color"] as? Int,
                  let allDay = data["allDay"] as? Bool,
                  let cycleOption = ScheduleData.CycleOption(rawValue: data["cycleOption"] as? String ?? "none"),
                  let location = data["location"] as? String,
                  let address = data["address"] as? String,
                  let description = data["description"] as? String else {
                return nil
            }

            return ScheduleData(
                id: UUID(uuidString: documentIdString)!,
                title: title,
                startDate: startDate.dateValue(),
                endDate: endDate.dateValue(),
                isChanging: false,
                allDay: allDay,
                cycleOption: cycleOption,
                location: location,
                address: address,
                description: description,
                color: color
            )
        }

        dict = Dictionary(uniqueKeysWithValues: schedules.map { ($0.id.uuidString, $0) })

        return dict.isEmpty ? nil : dict
    }}

// MARK: - Google 로그인 관련 기능
extension FirebaseViewModel {
    func signInGoogle() async {
        do {
            try await signInGoogleHelper()
            signedIn = true
        } catch {
            print("Google SignIn Error: \(error)")
        }
    }
    
    func signOutGoogle() async {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            try await GIDSignIn.sharedInstance.disconnect()
            signedIn = false
        } catch {
            print("Google SignOut Error: \(error)")
        }
    }
    
    private func signInGoogleHelper() async throws {
        guard let topVC = topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignIn = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignIn.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignIn.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        let result = try await Auth.auth().signIn(with: credential)

        saveUserToFirestore(user: result.user)
    }
    
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        let controller = controller ?? keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController, let selected = tabController.selectedViewController {
            return topViewController(controller: selected)
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}
