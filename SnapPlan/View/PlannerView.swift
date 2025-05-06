//
//  TimeView.swift
//  SnapPlan
//
//  Created by opfic on 12/31/24.
//

import SwiftUI

struct PlannerView: View {
    @StateObject var plannerVM = PlannerViewModel()
    @EnvironmentObject var firebaseVM: FirebaseViewModel
    @EnvironmentObject var uiVM: UIViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CalendarView()
                    .environmentObject(plannerVM)
                    .environmentObject(firebaseVM)
                    .environmentObject(uiVM)
                TimeLineView()
                    .environmentObject(plannerVM)
                    .environmentObject(firebaseVM)
                    .environmentObject(uiVM)
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

#Preview {
    PlannerView()
        .environmentObject(FirebaseViewModel())
}

