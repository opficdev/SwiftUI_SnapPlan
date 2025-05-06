//
//  ContentView.swift
//  SwiftUI_SnapPlan
//
//  Created by opfic on 12/30/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseVM = FirebaseViewModel()
    @StateObject private var uiVM = UIViewModel()
    @StateObject private var networkVM = NetworkViewModel()
    // 앱이 설치되고 첫번째 로딩인지 저장하는 AppStorage
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some View {
        ZStack {
            Color.calendar.ignoresSafeArea()
            if let signedIn = firebaseVM.signedIn {
                if signedIn && !isFirstLaunch {
                    PlannerView()
                        .environmentObject(firebaseVM)
                        .environmentObject(uiVM)
                        .environmentObject(networkVM)
                        .onAppear {
                            uiVM.setAppTheme(firebaseVM.screenMode)
                        }
                }
                else {
                    LoginView()
                        .environmentObject(firebaseVM)
                        .environmentObject(networkVM)
                        .onAppear {
                            if isFirstLaunch {
                                Task {
                                    try await firebaseVM.signOutGoogle()
                                    try await firebaseVM.signOutApple()
                                    isFirstLaunch = false
                                }
                            }
                        }
                }
            }
            else {  //  로그인을 시도하는 중(최초 로그인을 한 이후인 경우)
                Color.clear.onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        if firebaseVM.signedIn == nil {
                            Task {
                                try await firebaseVM.signOutGoogle()
                                try await firebaseVM.signOutApple()
                                isFirstLaunch = true
                            }
                        }
                    }
                }
            }
        }
        .alert("네트워크 문제", isPresented: $networkVM.showNetworkAlert) {
            Button(role: .cancel, action: {
                networkVM.showNetworkAlert = false
            }) {
                Text("확인")
            }
        } message: {
            Text("네트워크 연결을 확인해주세요")
        }
    }
}

#Preview {
    ContentView()
}
