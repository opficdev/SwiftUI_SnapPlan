//
//  TimeView.swift
//  SnapPlan
//
//  Created by opfic on 12/31/24.
//

import SwiftUI

struct PlannerView: View {
    @StateObject var viewModel = PlannerViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            CalendarView()
                .environmentObject(viewModel)
            TimeLineView()
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    PlannerView()
}

