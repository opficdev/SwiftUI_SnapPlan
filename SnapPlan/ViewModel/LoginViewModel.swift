//
//  LoginViewModel.swift
//  SnapPlan
//
//  Created by opfic on 12/30/24.
//
//  구글 소셜 로그인을 구현하는 뷰모델

import Foundation
import Combine
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var signedIn = Auth.auth().currentUser != nil
    
    func signInGoogle() async {
        do {
            try await signInGoogleHelper()
        }
        catch {
            print("Google SignIn Error: \(error)")
        }
    }
    
    func signOutGoogle() async {
        do {
            try Auth.auth().signOut()
            signedIn = false
        }
        catch {
            print("Google SignOut Error: \(error)")
        }
    }
}


extension LoginViewModel {
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        // 현재 화면의 rootViewController를 가져옴
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        let controller = controller ?? keyWindow?.rootViewController
        
        // UINavigationController 처리
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        // UITabBarController 처리
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        // 모달로 표시된 뷰 컨트롤러 처리
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        // 최상위 컨트롤러 반환
        return controller
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
        
        let _ = try await Auth.auth().signIn(with: credential)
        signedIn = true
    }
}
