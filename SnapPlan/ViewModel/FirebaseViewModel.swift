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
    @Published var signedIn: Bool? = nil
    @Published var is12TimeFmt: Bool = true
    @Published var screenMode: String = "auto"
    @Published var schedules: [ScheduleData] = []
    
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
                    await self.loadScheduleData()
                    self.signedIn = true
                }
            }
        }
    }
    
    /// 최초 앱 실행 시 사용자의 12시간제 포맷을 불러오는 메소드
    func loadTimeFormat() async {
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
    
    /// 최초 앱 실행 시 사용자의 오늘을 포함한 달의 전체 스케줄 데이터를 불러오는 메소드
    func loadScheduleData() async {
        do {
            if let value = try await fetchScheduleData(date: Date()) {
                await MainActor.run {
                    self.schedules = value
                }
            } 
        } catch {
            print("Schedule Load Error: \(error.localizedDescription)")
        }
    }
    
    /// 최초 앱 실행 시 스크린 모드를 불러오는 메소드
    func loadScreenMode() async {
        do {
            if let value = try await fetchScreenMode() {
                await MainActor.run {
                    self.screenMode = value
                }
            }
        } catch {
            print("ScreenMode Load Error: \(error.localizedDescription)")
        }
    }
    
    /// Firebase에 사용자 정보를 저장하는 메소드
    private func saveUserToFirestore(user: User) {
        let userRef = db.collection(user.uid).document("info")
        let userInfo: [String: Any] = [
            "uid": user.uid,    //  uid
            "email": user.email ?? "",  //  이메일
            "displayName": user.displayName ?? "",  //  닉네임
            "signedAt": FieldValue.serverTimestamp(),   //  가입 시간
            "is12TimeFmt": true,    //  12시간제 포맷 여부
            "screenMode": "auto"    //  화면 모드
        ]
        
        userRef.setData(userInfo, merge: true) { error in
            if let error = error {
                print("Error saving user: \(error.localizedDescription)")
            } else {
                print("User saved successfully!")
            }
        }
    }
    
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
    
    func setScreenMode(mode: String) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("info")
        
        do {
            try await docRef.setData(["screenMode": mode], merge: true)
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
            let screenMode = document.data()?["screenMode"] as? String ?? "auto"
            return screenMode
        } catch {
            throw error
        }
    }
    
    func addScheduleData(schedule: ScheduleData) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        let dateString = DateFormatter.yyyyMMdd.string(from: schedule.timeLine.0)
        
        let docRef = db.collection(userId).document("scheduleData").collection(dateString).document(schedule.id.uuidString)
        
        do {
            let document = try await docRef.getDocument()
            
            var schedules: [[String: Any]] = document.data()?[dateString] as? [[String: Any]] ?? []
            
            let newEntry: [String: Any] = [
                "title": schedule.title,
                "timeLine": [schedule.timeLine.0, schedule.timeLine.1],
                "cycleOption": schedule.cycleOption.rawValue,
                "location": schedule.location,
                "description": schedule.description,
                "color": schedule.color
            ]
            
            schedules.append(newEntry)
            
            try await docRef.setData([dateString: schedules], merge: true)
        } catch {
            throw error
        }
    }
    
    func fetchScheduleData(date: Date) async throws -> [ScheduleData]? {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection(userId).document("scheduleData")
        
        do {
            let document = try await docRef.getDocument()
            
            let dateString = DateFormatter.yyyyMMdd.string(from: date)
            
            guard let schedules = document.data()?[dateString] as? [[String: Any]] else {
                return nil
            }
            
            let scheduleArr: [ScheduleData] = schedules.compactMap { entry in
                guard let title = entry["title"] as? String,
                      let timeLine = entry["timeLine"] as? [Date],
                      let cycleOption = ScheduleData.CycleOption(rawValue: entry["cycleOption"] as? String ?? "none"),
                      let location = entry["location"] as? String,
                      let description = entry["description"] as? String,
                      let color = entry["color"] as? Int else { return nil }
                
                return ScheduleData(
                    title: title,
                    timeLine: (timeLine[0], timeLine[1]),
                    cycleOption: cycleOption,
                    location: location,
                    description: description, color: color
                )
            }
            
            return scheduleArr
        } catch {
            throw error
        }
    }
}

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
