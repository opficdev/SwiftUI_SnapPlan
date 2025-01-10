//
//  CalendarGrid.swift
//  SnapPlan
//
//  Created by opfic on 1/9/25.
//

import SwiftUI

struct CalendarGrid: View {
    @EnvironmentObject var viewModel: PlannerViewModel
    @Binding var wasPast: Bool  //  이전 날짜인지 확인
    @State private var monthData: [Date]
    let screenWidth = UIScreen.main.bounds.width
    
    init(wasPast: Binding<Bool>, monthData: [Date]) {
        self._monthData = State(initialValue: monthData)
        self._wasPast = wasPast
    }
        
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(0..<monthData.count / 7, id: \.self) { col in
                HStack {
                    ForEach(0..<7) { row in
                        Spacer()
                        CalendarCell(date: monthData[col * 7 + row], wasPast: $wasPast)
                            .environmentObject(viewModel)
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarGrid(
        wasPast: .constant(false),
        monthData: PlannerViewModel().calendarData[1]
    )
    .environmentObject(PlannerViewModel())
}
