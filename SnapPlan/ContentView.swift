//
//  ContentView.swift
//  SwiftUI_SnapPlan
//
//  Created by opfic on 12/30/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        if viewModel.signedIn {
            PlannerView()
        }
        else {
            LoginView()
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    ContentView()
}
