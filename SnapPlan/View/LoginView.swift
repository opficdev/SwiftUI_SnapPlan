//
//  LoginView.swift
//  SnapPlan
//
//  Created by opfic on 12/30/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var viewModel: LoginViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            Color.calendar.ignoresSafeArea()
            VStack {
                Spacer()
                if colorScheme == .light {
                    Image("light_logo")
                        .resizable()
                        .scaledToFit()
                }
                else {
                    Image("dark_logo")
                        .resizable()
                }
                Spacer()
                Group {
                    if colorScheme == .light {
                        Image("ios_light_sq_SI@4x")
                            .resizable()
                    }
                    else {
                        Image("ios_dark_sq_SI@4x")
                            .resizable()
                    }
                }
                .scaledToFit()
                .frame(width: screenWidth / 2)
                .onTapGesture {
                    Task {
                        await viewModel.signInGoogle()
                    }
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
        .environmentObject(LoginViewModel())
}
