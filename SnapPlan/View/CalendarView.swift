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
    @State private var scrollId = (0,5) //  캘린더에 보여지는 최소, 최대 id
    @State private var calendarSpacing: CGFloat = 0  //  캘린더 행 간의 간격
    @State private var daysHeight = CGFloat.zero  //  날짜 보여주는 부분의 height
    @State private var showCalendar = true // 전체 달력을 보여줄지 여부
    @State private var wasPast = false  //  새로운 selectDate가 기존 selectDate 이전인지 여부

    
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
                                        wasPast = viewModel.selectDate < viewModel.today
                                        viewModel.selectDate = viewModel.today
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
                        
                        ScrollViewReader { proxy in
                            ScrollView(showsIndicators: false) {
                                LazyVStack(spacing: 0) {
                                    let calendarData = viewModel.calendarData
                                    ForEach(Array(zip(calendarData.indices, calendarData)), id: \.1) { index, month in
                                        CalendarGrid(
                                            wasPast: $wasPast,
                                            monthData: month
                                        )
                                        .environmentObject(viewModel)
                                        .id(index)
                                        .onAppear {
                                            if calendarData.count == 1 {
                                                viewModel.setCalendarData(date: viewModel.today)
                                                DispatchQueue.main.async {
                                                    proxy.scrollTo(1, anchor: .top)
                                                }
                                            }
                                        }
                                    }
                                }
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onAppear {
                                            if daysHeight == CGFloat.zero {
                                                daysHeight = geometry.size.height
                                            }
                                        }
                                    }
                                )
                            }
                            .frame(height: daysHeight, alignment: .top)     //  .top으로 정렬해야 자연스러운 애니메이션
//                            .allowsHitTesting(!isScrolling)
                        }
                    }
                }
            }
            .background(Color.calendarBackground)
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(PlannerViewModel())
}
