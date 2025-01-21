//
//  CalendarView.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//

import Foundation
import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var plannerVM: PlannerViewModel
    @EnvironmentObject private var loginVM: LoginViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showCalendar = false // 전체 달력을 보여줄지 여부
    @State private var selection = 1  //  선택된 달력의 tag
    
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
         VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(systemName: "line.3.horizontal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth / 18)
                    .foregroundStyle(Color.gray)
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 8)) //  월 보여주는거 때문에 16 - 8
                    .onTapGesture {
                        Task {
                            await loginVM.signOutGoogle()
                        }
                    }
                HStack(spacing: 4) {
                    Text(plannerVM.getCurrentMonthYear())
                        .font(.title)
                        .bold()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(
                            (colorScheme == .light ? Color.black : Color.white)
                                .opacity(showCalendar ? 1 : 0.5)
                        )
                        .rotationEffect(.degrees(showCalendar ? -180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: showCalendar ? 180 : 0) // 애니메이션 적용
                }
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            Color.gray.opacity(
                                showCalendar ? 0.3 : 0
                            )
                        )
                )
                .onTapGesture {
                    withAnimation(.linear(duration: 0.1)) {
                        showCalendar.toggle()
                    }
                }
                Spacer()
                
                
                Text(plannerVM.dateString(date: plannerVM.today, component: .day))
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                    .frame(width: screenWidth / 14, height: screenWidth / 14)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                plannerVM.isSameDate(date1: plannerVM.today, date2: plannerVM.selectDate, components: [.year, .month, .day])
                                ? Color.gray.opacity(0.5) : Color.timeBar
                            )
                    )
                    .onTapGesture{
                        if !plannerVM.isSameDate(date1: plannerVM.today, date2: plannerVM.selectDate, components: [.year, .month, .day]) {
                            withAnimation {
                                plannerVM.wasPast = plannerVM.selectDate < plannerVM.today
                                plannerVM.selectDate = plannerVM.today
                                selection = 1
                            }
                        }
                    }
            }
            .padding(.horizontal)
            
            if showCalendar {
                VStack(spacing: 0) {
                    HStack {
                        ForEach(plannerVM.daysOfWeek, id: \.self) { day in
                            Spacer()
                            Text(day)
                                .foregroundStyle(Color.gray)
                                .font(.caption)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 8)
                    
                    TabView(selection: $selection) {
                        let calendarData = plannerVM.calendarData
                        ForEach(Array(zip(calendarData.indices, calendarData)), id: \.1) { idx, month in
                            CalendarGrid(monthData: month, wasPast: $plannerVM.wasPast)
                                .environmentObject(plannerVM)
                                .tag(idx)
                                .onDisappear {
                                    if selection == 0 {
                                        let lastDate = plannerVM.date(byAdding: .month, value: -2, to: plannerVM.currentDate)!
                                        let lastMonth = plannerVM.calendarDates(date: lastDate)
                                        plannerVM.calendarData.insert(lastMonth, at: 0)
                                        plannerVM.calendarData.removeLast()
                                        plannerVM.currentDate = plannerVM.date(byAdding: .month, value: -1, to: plannerVM.currentDate)!
                                    }
                                    else if selection == 2 {
                                        let nextDate = plannerVM.date(byAdding: .month, value: 2, to: plannerVM.currentDate)!
                                        let nextMonth = plannerVM.calendarDates(date: nextDate)
                                        plannerVM.calendarData.append(nextMonth)
                                        plannerVM.calendarData.removeFirst()
                                        plannerVM.currentDate = plannerVM.date(byAdding: .month, value: 1, to: plannerVM.currentDate)!
                                    }
                                    selection = 1
                                }
                        }
                        .onChange(of: plannerVM.selectDate) { newDate in
                            plannerVM.currentDate = newDate
                            if !plannerVM.isSameDate(date1: newDate, date2: plannerVM.calendarData[1][15], components: [.year, .month]) {
                                plannerVM.setCalendarData(date: newDate)
                            }
                            selection = 1
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: screenWidth * 0.6)
                    .onAppear {
                        DispatchQueue.main.async {
                            selection = 1
                        }
                    }
                }
            }
        }
         .background(Color.calendar)
    }
}

#Preview {
    CalendarView()
        .environmentObject(PlannerViewModel())
}
