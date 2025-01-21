//
//  TimeView.swift
//  SnapPlan
//
//  Created by opfic on 12/31/24.
//

import SwiftUI

struct PlannerView: View {
    @StateObject var plannerVM = PlannerViewModel()
    @StateObject var firebaseVM = FirebaseViewModel()
    @EnvironmentObject var loginVM: LoginViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                CalendarView()
                    .environmentObject(plannerVM)
                    .environmentObject(loginVM)
                TimeLineView()
                    .environmentObject(plannerVM)
            }
        }
    }
}

#Preview {
    PlannerView()
        .environmentObject(LoginViewModel())
}

