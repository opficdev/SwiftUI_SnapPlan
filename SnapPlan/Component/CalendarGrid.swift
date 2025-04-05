//
//  CalendarGrid.swift
//  SnapPlan
//
//  Created by opfic on 1/9/25.
//

import SwiftUI

struct CalendarGrid: View {
    @EnvironmentObject var plannerVM: PlannerViewModel
    @State private var monthData: [Date]
    let screenWidth = UIScreen.main.bounds.width
    
    init(monthData: [Date]) {
        self._monthData = State(initialValue: monthData)
    }
        
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(0..<monthData.count / 7, id: \.self) { col in
                HStack {
                    ForEach(0..<7) { row in
                        Spacer()
                        CalendarCell(date: monthData[col * 7 + row])
                            .environmentObject(plannerVM)
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarGrid(monthData: PlannerViewModel().calendarData[1])
    .environmentObject(PlannerViewModel())
}
