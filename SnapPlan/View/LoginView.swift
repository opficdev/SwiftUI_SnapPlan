//
//  LoginView.swift
//  SnapPlan
//
//  Created by opfic on 12/30/24.
//

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject private var viewModel: FirebaseViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var loginBtnHeight: CGFloat = 0
    
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
                VStack(spacing: 20) {
                    GoogleSignInButton(scheme: colorScheme == .light ? .dark : .light, style: .wide, state: .pressed) {
                        Task {
                            try await viewModel.signInGoogle()
                        }
                    }
                    .frame(width: screenWidth / 2)
                    .removeShadow()
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onAppear {
                                loginBtnHeight = geometry.size.height
                            }
                        }
                    )
                    
                    AppleSignInButton(cornerRadius: 2, action: {    //  GoogleSignInButtonStyling.swift에 정의된 cornerRadius
                        Task {
                            try await viewModel.signInApple()
                        }
                    })
                    .frame(width:screenWidth / 2, height: loginBtnHeight)
                    .id(colorScheme == .light ? "light-btn": "dark-btn")    //  래퍼 내에서는 변경되지만 SwiftUI에서 변경되지 않아서 id 업데이트로 강제 테마 변경
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

#Preview {
    LoginView()
        .environmentObject(FirebaseViewModel())
}
