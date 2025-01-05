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
    @State private var weekHeight: CGFloat = 0  //  요일 보여주는 부분의 height
    @State private var daysHeight: CGFloat = 0  //  날짜 보여주는 부분의 height
    @State private var showCalendar = false // 전체 달력을 보여줄지 여부
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
                    .background(
                        GeometryReader { geometry in
                            Color.clear.onAppear {
                                weekHeight = geometry.size.height
                            }
                        }
                    )
                    .padding(.vertical, 8)
                    
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: calendarSpacing) {
                                ForEach(Array(zip(viewModel.calendarData.indices, viewModel.calendarData)), id: \.0) { idx, week in
                                    HStack(spacing: 0) {
                                        ForEach(week, id: \.self) { date in
                                            Spacer()
                                                .background(
                                                    GeometryReader { geometry in
                                                        Color.clear.onAppear {
                                                            calendarSpacing = geometry.size.width
                                                        }
                                                    }
                                                )
                                            ZStack {
                                                if viewModel.dateCompare(date1: date, date2: viewModel.selectDate, components: [.year, .month, .day]) {
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
                                                            wasPast = viewModel.currentDate < date
                                                            viewModel.currentDate = date
                                                        }
                                                    }
                                            }
                                            .onAppear {
                                                if idx < scrollId.0 {

                                                    scrollId.0 = idx
                                                    scrollId.1 = idx + 5
                                                }
                                                else if scrollId.1 < idx {

                                                    scrollId.0 = idx - 5
                                                    scrollId.1 = idx
                                                }
                                            }
                                            Spacer()
                                        }
                                    }
                                    .id(idx)
                                    .background(
                                        GeometryReader { geometry in
                                            Color.clear.onAppear {
                                                daysHeight = geometry.size.height
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .onAppear {
                            viewModel.calendarData = viewModel.calendarDates(date: viewModel.today)
                        }
                        .onChange(of: viewModel.selectDate) { newDate in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {   //  transition 애니메이션 이후에 실행되어야 함
                                viewModel.setCalendarData(date: newDate)
                                if let idx = viewModel.findFirstDayofMonthIndex(date: newDate) {
                                    withAnimation {
                                        proxy.scrollTo(idx, anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: showCalendar ? weekHeight + daysHeight * 6 + calendarSpacing * 5 + 16 : 0, alignment: .top)
                //  height 구조: 요일 HStack의 height and 위아래 패딩 + 각 열의 height * 6(캘린더가 6행임) + 행 사이의 spacing(5개)
                //  .top으로 정렬해야 자연스러운 애니메이션
                .clipped()
            }
            .background(Color.gray.opacity(0.1))
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(PlannerViewModel())
}
