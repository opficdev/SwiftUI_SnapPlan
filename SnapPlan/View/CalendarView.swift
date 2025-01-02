//
//  CalendarView.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//

import SwiftUI
import Foundation

struct CalendarView: View {
    @EnvironmentObject private var viewModel: PlannerViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var currentIndex = 1 //
    
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
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
                        Image(systemName: "chevron.\(viewModel.showFullCalendar ? "up" : "down")")
                            .foregroundStyle(
                                Color.black.opacity(
                                    viewModel.showFullCalendar ? 1 : 0.5
                                )
                            )
                    }
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                Color.gray.opacity(
                                    viewModel.showFullCalendar ? 0.3 : 0
                                )
                            )
                    )
                    .onTapGesture {
                        viewModel.showFullCalendar.toggle()
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
                                        viewModel.dateCompare(date1: Date(), date2: viewModel.selectDate, components: [.year, .month, .day]) ? Color.gray.opacity(0.5) : Color.pink
                                    )
                            )
                            .onTapGesture{
                                withAnimation {
                                    if !viewModel.dateCompare(date1: viewModel.today, date2: viewModel.selectDate, components: [.year, .month, .day]) {
                                        viewModel.selectDate = viewModel.today
                                        viewModel.currentDate = viewModel.today
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal)
                
                if viewModel.showFullCalendar {
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
                
                    ScrollView(showsIndicators: false) {
                        ForEach(Array(zip(viewModel.calendarData.indices, viewModel.calendarData)), id: \.0) { idx, week in
                            HStack(spacing: 0) {
                                ForEach(week, id: \.self) { date in
                                    Spacer()
                                    ZStack {
                                        if viewModel.dateCompare(date1: date, date2: viewModel.selectDate, components: [.year, .month, .day]) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    Color.gray.opacity(0.5)
                                                )
                                                .frame(width: screenWidth / 10, height: screenWidth / 10)
                                                .transition(.asymmetric(
                                                    insertion: .move(edge: viewModel.wasPast ? .leading : .trailing).combined(with: .opacity),
                                                    removal: .identity
                                                ))
                                        }
                                        
                                        if viewModel.dateCompare(date1: date, date2: Date(), components: [.year, .month, .day]) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.pink)
                                                .frame(width: screenWidth / 12, height: screenWidth / 12)
                                        }
                                            
                                        Text(viewModel.dateString(date: date, component: .day))
                                            .font(.subheadline)
                                            .foregroundStyle(viewModel.setDayForegroundColor(date: date, colorScheme: colorScheme))
                                            .frame(width: screenWidth / 10, height: screenWidth / 10)
                                            .onTapGesture {
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    viewModel.selectDate = date
                                                    viewModel.wasPast = viewModel.currentDate < date
                                                    viewModel.currentDate = date
                                                }
                                            }
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .onAppear {
                            DispatchQueue.main.async {
                                viewModel.setCalendarData(date: viewModel.currentDate)
                            }
                        }
                        .background(
                            GeometryReader { geometry in
                                Color.clear.onAppear {
                                    viewModel.calendarHeight = geometry.size.height
                                }
                            }
                        )
                    }
//                    .frame(height: viewModel.calendarHeight)
                }
            }
            .background(Color.gray.opacity(0.1))
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(PlannerViewModel())
}
