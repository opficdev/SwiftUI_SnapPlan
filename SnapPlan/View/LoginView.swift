//
//  LoginView.swift
//  SnapPlan
//
//  Created by opfic on 12/30/24.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject private var firebaseVM: FirebaseViewModel
    @EnvironmentObject private var networkVM: NetworkViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            Color.calendar.ignoresSafeArea()
            VStack {
                Spacer()
                Group {
                    if colorScheme == .light {
                        Image("light_logo")
                            .resizable()
                    }
                    else {
                        Image("dark_logo")
                            .resizable()
                    }
                }
                .scaledToFit()
                .frame(width: screenWidth / 5)
                Spacer()
                Text("스냅플랜에 오신 것을 환영합니다")
                    .font(.title2)
                    .bold()
                Spacer()
                VStack(spacing: 20) {
                    LoginButton(text: "구글 계정으로 로그인") {
                        if networkVM.isConnected {
                            Task {
                                try await firebaseVM.signInGoogle()
                            }
                        }
                        else {
                            networkVM.showNetworkAlert = true
                        }
                    }
                    .frame(width: screenWidth * 3 / 4, height: screenWidth / 13)
                        
                    LoginButton(text: "애플 계정으로 로그인") {
                        if networkVM.isConnected {
                            Task {
                                try await firebaseVM.signInGoogle()
                            }
                        }
                        else {
                            networkVM.showNetworkAlert = true
                        }
                    }
                    .frame(width: screenWidth * 3 / 4, height: screenWidth / 13)
                }
                
                Spacer()
                Text("로그인하면 약관과 개인정보 보호정책을 확인하고 동의하는 것으로 간주됩니다")
                    .font(.caption2)
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.bottom)
            }
        }
    }
}
