//
//  ContentView.swift
//  SwiftUI_SnapPlan
//
//  Created by opfic on 12/30/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseVM = FirebaseViewModel()
    
    var body: some View {
        ZStack {
            Color.calendar.ignoresSafeArea()
            if let signedIn = firebaseVM.signedIn {
                if signedIn {
                    PlannerView()
                        .environmentObject(firebaseVM)
                }
                else {
                    LoginView()
                        .environmentObject(firebaseVM)
                }
            }
            else {  //  로그인을 시도하는 중(최초 로그인을 한 이후인 경우)

            }
        }
    }
}

#Preview {
    ContentView()
}
