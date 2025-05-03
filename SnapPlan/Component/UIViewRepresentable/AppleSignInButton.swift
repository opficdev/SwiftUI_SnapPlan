//
//  AppleSignInButton.swift
//  SnapPlan
//
//  Created by opfic on 4/22/25.
//

import SwiftUI
import AuthenticationServices

struct AppleSignInButton: UIViewRepresentable {
    var type: ASAuthorizationAppleIDButton.ButtonType = .signIn
    var cornerRadius: CGFloat?
    var action: () -> Void
    
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        let style: ASAuthorizationAppleIDButton.Style = context.environment.colorScheme == .dark ? .white : .black
        let button = ASAuthorizationAppleIDButton(type: type, style: style)
        if let cornerRadius = cornerRadius {
            button.cornerRadius = cornerRadius
        }
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        return button
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator: NSObject {
        var action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func buttonTapped() {
            action()
        }
    }
}
