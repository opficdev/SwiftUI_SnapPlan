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
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(viewModel.calendarData[1], id: \.self) { date in
                CalendarCell(date: date, wasPast: $wasPast)
                    .environmentObject(viewModel)
            }
        }
    }
}

#Preview {
    CalendarGrid(
        wasPast: .constant(false)
    )
    .environmentObject(PlannerViewModel())
}
