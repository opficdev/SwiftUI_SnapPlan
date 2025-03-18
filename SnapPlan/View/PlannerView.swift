//
//  TimeView.swift
//  SnapPlan
//
//  Created by opfic on 12/31/24.
//

import SwiftUI

struct PlannerView: View {
    @StateObject var plannerVM = PlannerViewModel()
    @EnvironmentObject var supabaseVM: SupabaseViewModel
    @State private var showScheduleView = true
    @State private var showSettingView = false
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView(showScheduleView: $showScheduleView, showSettingView: $showSettingView)
                .environmentObject(plannerVM)
                .environmentObject(supabaseVM)
            TimeLineView(showScheduleView: $showScheduleView)
                .environmentObject(plannerVM)
                .environmentObject(supabaseVM)
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    PlannerView()
        .environmentObject(SupabaseViewModel())
}

