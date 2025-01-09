//
//  CalendarCell.swift
//  SnapPlan
//
//  Created by opfic on 1/9/25.
//

import SwiftUI

struct CalendarCell: View {
    @EnvironmentObject var viewModel: PlannerViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var wasPast: Bool //  이전 날짜인지 확인
    @State private var date: Date //  셀의 날짜
    let screenWidth = UIScreen.main.bounds.width
    
    init(date: Date, wasPast: Binding<Bool>) {
        self._date = State(initialValue: date)
        self._wasPast = wasPast
    }
    
    var body: some View {
        ZStack {
            if viewModel.isSameDate(date1: date, date2: viewModel.selectDate, components: [.year, .month, .day]) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        Color.gray.opacity(0.5)
                    )
                    .frame(width: screenWidth / 10, height: screenWidth / 10)
                    .transition(.asymmetric(
                        insertion: .move(edge: wasPast ? .leading : .trailing).combined(with: .opacity),
                        removal: .identity
                    ))
            }
            
            if viewModel.isSameDate(date1: date, date2: viewModel.today, components: [.year, .month, .day]) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.pink)
                    .frame(width: screenWidth / 12, height: screenWidth / 12)
            }
            
            Text(viewModel.dateString(date: date, component: .day))
                .font(.subheadline)
                .foregroundStyle(viewModel.setDayForegroundColor(date: date, colorScheme: colorScheme))
                .frame(width: screenWidth / 10, height: screenWidth / 10)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                wasPast = viewModel.selectDate < date
                viewModel.selectDate = date
            }
        }
    }
}

#Preview {
    CalendarCell(
        date: Date(),
        wasPast: .constant(false)
    )
    .environmentObject(PlannerViewModel())
}
