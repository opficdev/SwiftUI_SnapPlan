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
    @Published var signedIn = Auth.auth().currentUser != nil
    private let db = Firestore.firestore()
    private var userId: String? { Auth.auth().currentUser?.uid }
    
    func addScheduleData(date: String, schedule: ScheduleData, completion: @escaping (Error?) -> Void) {
        guard let userId = userId else {
            completion(URLError(.userAuthenticationRequired))
            return
        }
        
        let docRef = db.collection("ScheduleData").document(userId).collection("dates").document(date)
        
        docRef.getDocument { document, error in
            if let error = error {
                completion(error)
                return
            }
            
//            var existingData: [[String: Any]] = document?.data()?["entries"] as? [[String: Any]] ?? []
            
            let newEntry: [String: Any] = [
                "title": schedule.title,
                "timeLine": schedule.timeLine,
                "cycleOption": schedule.cycleOption,
                "location": schedule.location,
                "description": schedule.description,
                "color": schedule.color
            ]
            
//            existingData.append(newEntry)
            
//            docRef.setData(["entries": existingData], merge: true, completion: completion)
            docRef.setData(["entries": newEntry], merge: true, completion: completion)
        }
    }
    
    func fetchScheduleData(date: String, completion: @escaping ([ScheduleData]?, Error?) -> Void) {
        guard let userId = userId else {
            completion(nil, URLError(.userAuthenticationRequired))
            return
        }
        
        let docRef = db.collection("ScheduleData").document(userId).collection("dates").document(date)
        
        docRef.getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let entries = document?.data()?["entries"] as? [[String: Any]] else {
                completion(nil, nil)
                return
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
            
            completion(timeDataList.isEmpty ? nil : timeDataList, nil)
        }
    }
    
    func set12TimeFmt(timeFmt: Bool, completion: @escaping (Error?) -> Void) {
        guard let userId = userId else {
            completion(URLError(.userAuthenticationRequired))
            return
        }
        
        let docRef = db.collection("users").document(userId)
        docRef.setData(["timeFmt": timeFmt], merge: true, completion: completion)
    }
    
    func fetch12Time(completion: @escaping (Bool?, Error?) -> Void) {
        guard let userId = userId else {
            completion(nil, URLError(.userAuthenticationRequired))
            return
        }
        
        let docRef = db.collection("users").document(userId)
        
        docRef.getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let timeFmt = document?.data()?["timeFmt"] as? Bool
            completion(timeFmt, nil)
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
