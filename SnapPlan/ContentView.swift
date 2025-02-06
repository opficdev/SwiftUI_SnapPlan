//
//  ContentView.swift
//  SwiftUI_SnapPlan
//
//  Created by opfic on 12/30/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FirebaseViewModel()
    
    var body: some View {
        if let signedIn = viewModel.signedIn {
            if signedIn {
                PlannerView()
                    .environmentObject(viewModel)
            }
            else {
                LoginView()
                    .environmentObject(viewModel)
            }
        }
        else {
            //  인터넷에 연결할 수 없을 경우일 때
        }
    }
}

#Preview {
    ContentView()
}
