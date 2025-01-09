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
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    init(wasPast: Binding<Bool>, monthData: [Date]) {
        self._monthData = State(initialValue: monthData)
        self._wasPast = wasPast
    }
        
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(monthData, id: \.self) { date in
                CalendarCell(date: date, wasPast: $wasPast)
                    .environmentObject(viewModel)
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
