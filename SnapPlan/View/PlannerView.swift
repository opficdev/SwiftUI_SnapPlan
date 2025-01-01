//
//  TimeView.swift
//  SnapPlan
//
//  Created by opfic on 12/31/24.
//

import SwiftUI

struct PlannerView: View {
    @StateObject var viewModel = PlannerViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView()
                .environmentObject(viewModel)
            ScheduleView()
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    PlannerView()
}
