//
//  CalendarCell.swift
//  SnapPlan
//
//  Created by opfic on 1/9/25.
//

import SwiftUI

struct CalendarCell: View {
    @EnvironmentObject var plannerVM: PlannerViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var date: Date //  셀의 날짜
    let screenWidth = UIScreen.main.bounds.width
    
    init(date: Date) {
        self._date = State(initialValue: date)
    }
    
    var body: some View {
        ZStack {
            if plannerVM.isSameDate(date1: date, date2: plannerVM.selectDate, components: [.year, .month, .day]) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        Color.gray.opacity(0.5)
                    )
                    .frame(width: screenWidth / 10, height: screenWidth / 10)
                    .transition(.asymmetric(
                        insertion: .move(edge: plannerVM.wasPast ? .leading : .trailing).combined(with: .opacity),
                        removal: .identity
                    ))
            }
            
            if plannerVM.isSameDate(date1: date, date2: plannerVM.today, components: [.year, .month, .day]) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.timeBar)
                    .frame(width: screenWidth / 12, height: screenWidth / 12)
            }
            
            Text(plannerVM.dateString(date: date, component: .day))
                .font(.subheadline)
                .foregroundStyle(plannerVM.setDayForegroundColor(date: date, colorScheme: colorScheme))
                .frame(width: screenWidth / 10, height: screenWidth / 10)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                plannerVM.userTapped = true
                plannerVM.selectDate = date
            }
        }
    }
}

#Preview {
    CalendarCell(date: Date())
    .environmentObject(PlannerViewModel())
}
