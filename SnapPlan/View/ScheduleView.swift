//
//  ScheduleView.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject private var viewModel: PlannerViewModel
    @Environment(\.colorScheme) var colorScheme
    
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
        }
    }
}

#Preview {
    ScheduleView()
        .environmentObject(PlannerViewModel())
}
