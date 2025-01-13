//
//  CalendarView.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//

import Foundation
import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var viewModel: PlannerViewModel
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
                        
                    }
                HStack(spacing: 4) {
                    Text(viewModel.getCurrentMonthYear())
                        .font(.title)
                        .bold()
                    Image(systemName: "chevron.\(showCalendar ? "up" : "down")")
                        .foregroundStyle(
                            Color.black.opacity(
                                showCalendar ? 1 : 0.5
                            )
                        )
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
                
                Group {
                    Text(viewModel.dateString(date: viewModel.today, component: .day))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .frame(width: screenWidth / 14, height: screenWidth / 14)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    viewModel.isSameDate(date1: viewModel.today, date2: viewModel.selectDate, components: [.year, .month, .day]) ? Color.gray.opacity(0.5) : Color.pink
                                )
                        )
                        .onTapGesture{
                            if !viewModel.isSameDate(date1: viewModel.today, date2: viewModel.selectDate, components: [.year, .month, .day]) {
                                withAnimation {
                                    viewModel.wasPast = viewModel.selectDate < viewModel.today
                                    viewModel.selectDate = viewModel.today
                                    selection = 1
                                }
                            }
                        }
                }
            }
            .padding(.horizontal)
            
            if showCalendar {
                VStack(spacing: 0) {
                    HStack {
                        ForEach(viewModel.daysOfWeek, id: \.self) { day in
                            Spacer()
                            Text(day)
                                .foregroundStyle(Color.gray)
                                .font(.caption)
                            Spacer()
                        }
                    }
                    .padding(.vertical, 8)
                    
                    TabView(selection: $selection) {
                        let calendarData = viewModel.calendarData
                        ForEach(Array(zip(calendarData.indices, calendarData)), id: \.1) { idx, month in
                            CalendarGrid(monthData: month, wasPast: $viewModel.wasPast)
                                .environmentObject(viewModel)
                                .tag(idx)
                                .onDisappear {
                                    if selection == 0 {
                                        let lastDate = viewModel.date(byAdding: .month, value: -2, to: viewModel.currentDate)!
                                        let lastMonth = viewModel.calendarDates(date: lastDate)
                                        viewModel.calendarData.insert(lastMonth, at: 0)
                                        viewModel.calendarData.removeLast()
                                        viewModel.currentDate = viewModel.date(byAdding: .month, value: -1, to: viewModel.currentDate)!
                                    }
                                    else if selection == 2 {
                                        let nextDate = viewModel.date(byAdding: .month, value: 2, to: viewModel.currentDate)!
                                        let nextMonth = viewModel.calendarDates(date: nextDate)
                                        viewModel.calendarData.append(nextMonth)
                                        viewModel.calendarData.removeFirst()
                                        viewModel.currentDate = viewModel.date(byAdding: .month, value: 1, to: viewModel.currentDate)!
                                    }
                                    selection = 1
                                }
                        }
                        .onChange(of: viewModel.selectDate) { newDate in
                            viewModel.currentDate = newDate
                            if !viewModel.isSameDate(date1: newDate, date2: viewModel.calendarData[1][15], components: [.year, .month]) {
                                viewModel.setCalendarData(date: newDate)
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
         .background(Color.calendarBackground)
    }
}

#Preview {
    CalendarView()
        .environmentObject(PlannerViewModel())
}
