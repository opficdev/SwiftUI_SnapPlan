//
//  ContentView.swift
//  SwiftUI_SnapPlan
//
//  Created by opfic on 12/30/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseVM = FirebaseViewModel()
    // 앱이 설치되고 첫번째 로딩인지 저장하는 AppStorage
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    var body: some View {
        ZStack {
            Color.calendar.ignoresSafeArea()
            if let signedIn = firebaseVM.signedIn {
                if signedIn && !isFirstLaunch {
                    PlannerView()
                        .environmentObject(firebaseVM)
                }
                else {
                    LoginView()
                        .environmentObject(firebaseVM)
                        .onAppear {
                            if isFirstLaunch {
                                Task {
                                    try await firebaseVM.signOutGoogle()
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
                                isFirstLaunch = true
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
