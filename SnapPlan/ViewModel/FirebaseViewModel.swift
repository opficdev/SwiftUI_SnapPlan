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
    @Published var schedules: [ScheduleData] = []
    
    init() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("이전 로그인 복원 실패: \(error.localizedDescription)")
                return
            }
            
            if let _ = user {
                Task {
                    await self.loadTimeFormat()
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
            } else {
                try await set12TimeFmt(timeFmt: true)
            }
        } catch {
            print(error.localizedDescription)
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
            print(error.localizedDescription)
        }
    }
    
    func set12TimeFmt(timeFmt: Bool) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection("users").document(userId)
        
        do {
            try await docRef.setData(["timeFmt": timeFmt], merge: true)
        } catch {
            throw error
        }
    }
    
    func fetch12TimeFmt() async throws -> Bool? {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let docRef = db.collection("users").document(userId)
        
        do {
            let document = try await docRef.getDocument()
            let timeFmt = document.data()?["timeFmt"] as? Bool
            return timeFmt
        } catch {
            throw error
        }
    }
    
    func addScheduleData(date: Date, schedule: ScheduleData) async throws {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        let dateString = DateFormatter.yyyyMMdd.string(from: date)
        
        let docRef = db.collection("ScheduleData").document(userId).collection("dates").document(dateString)
        
        do {
            let document = try await docRef.getDocument()
            
            var entries: [[String: Any]] = document.data()?["entries"] as? [[String: Any]] ?? []
            
            let newEntry: [String: Any] = [
                "title": schedule.title,
                "timeLine": schedule.timeLine,
                "isChanging": schedule.isChanging,
                "cycleOption": schedule.cycleOption,
                "location": schedule.location,
                "description": schedule.description,
                "color": schedule.color
            ]
            
            entries.append(newEntry)
            
            try await docRef.setData(["entries": entries], merge: true)
        } catch {
            throw error
        }
    }
    
    func fetchScheduleData(date: Date) async throws -> [ScheduleData]? {
        guard let userId = userId else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let date = DateFormatter.yyyyMMdd.string(from: date)
        
        let docRef = db.collection("ScheduleData").document(userId).collection("dates").document(date)
        
        do {
            let document = try await docRef.getDocument()
            
            guard let entries = document.data()?["entries"] as? [[String: Any]] else {
                return nil
            }
            
            let timeDataList: [ScheduleData] = entries.compactMap { entry in
                guard let title = entry["title"] as? String,
                      let timeLine = entry["timeLine"] as? (Date, Date),
                      let cycleOption = entry["cycleOption"] as? ScheduleData.CycleOption,
                      let location = entry["location"] as? String,
                      let description = entry["description"] as? String,
                      let color = entry["color"] as? Int else { return nil }
                return ScheduleData(title: title, timeLine: timeLine, cycleOption: cycleOption, location: location, description: description, color: color)
            }
            
            return timeDataList
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
        } catch {
            print("Google SignIn Error: \(error)")
        }
    }
    
    func signOutGoogle() async {
        do {
            try Auth.auth().signOut()
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
        signedIn = true
    }
    
    private func saveUserToFirestore(user: User) {
        let userRef = db.collection("users").document(user.uid)
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "displayName": user.displayName ?? "",
            "signedAt": FieldValue.serverTimestamp()
        ]
        
        userRef.setData(userData, merge: true) { error in
            if let error = error {
                print("Error saving user: \(error.localizedDescription)")
            } else {
                print("User saved successfully!")
            }
        }
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
