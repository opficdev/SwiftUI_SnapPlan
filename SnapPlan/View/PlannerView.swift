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
    @State private var showSideBar = false
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView(showSideBar: $showSideBar)
                .environmentObject(plannerVM)
                .environmentObject(firebaseVM)
            TimeLineView()
                .environmentObject(plannerVM)
        }
    }
}

#Preview {
    PlannerView()
        .environmentObject(FirebaseViewModel())
}

