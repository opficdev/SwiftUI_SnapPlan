//
//  CalendarView.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//

import SwiftUI
import SwiftUIIntrospect

struct CalendarView: View {
    @EnvironmentObject private var plannerVM: PlannerViewModel
    @EnvironmentObject private var firebaseVM: FirebaseViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var showScheduleView: Bool
    @Binding var showSettingView: Bool
    @State private var showCalendar = false // 전체 달력을 보여줄지 여부
    @State private var dragByUser = false
    
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
                        showScheduleView = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSettingView = true
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
                    if !showCalendar {
                        plannerVM.currentDate = plannerVM.selectDate
                    }
                }
                Spacer()
                NavigationLink(destination: SearchScheduleView()) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.gray)
                        .padding(.trailing)
                }
                
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
                            withAnimation(.easeInOut(duration: 0.1)) {
                                plannerVM.userTapped = true
                                plannerVM.selectDate = Calendar.current.startOfDay(for: plannerVM.today)
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
                    
                    ScrollViewReader { scrollProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(Array(zip(plannerVM.calendarData.indices, plannerVM.calendarData)), id: \.1) { idx, month in
                                    CalendarGrid(monthData: month)
                                        .environmentObject(plannerVM)
                                        .id(idx)
                                        .background(
                                            GeometryReader { proxy in
                                                Color.clear.onChange(of: proxy.frame(in: .global)) { frame in
                                                    if dragByUser && Int(frame.minX) == 0 {
                                                        dragByUser = false
                                                        if idx == 0 {
                                                            let prevDate = plannerVM.date(byAdding: .month, value: -1, to: plannerVM.currentDate)!
                                                            plannerVM.setCalendarData(date: prevDate)
                                                            plannerVM.currentDate = prevDate
                                                        }
                                                        else if idx == 2 {
                                                            let nextDate = plannerVM.date(byAdding: .month, value: 1, to: plannerVM.currentDate)!
                                                            plannerVM.setCalendarData(date: nextDate)
                                                            plannerVM.currentDate = nextDate
                                                        }
                                                        scrollProxy.scrollTo(1, anchor: .center)
                                                    }
                                                }
                                            }
                                        )
                                }
                                .frame(width: CGFloat(Int(screenWidth)), height: screenWidth * 0.6)
                                .onAppear {
                                    DispatchQueue.main.async {
                                        scrollProxy.scrollTo(1, anchor: .center)
                                    }
                                }
                            }
                        }
                        .frame(width: CGFloat(Int(screenWidth)), height: screenWidth * 0.6)
                        .pagingEnabled()
                    }
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { _ in
                                dragByUser = true
                            }
                    )
                }
            }
        }
        .background(Color.calendar)
        .fullScreenCover(isPresented: $showSettingView) {
            SettingView()
                .environmentObject(firebaseVM)
                .onDisappear {
                    showScheduleView = true
                }
        }
    }
}

#Preview {
    CalendarView(
        showScheduleView: .constant(true),
        showSettingView: .constant(false)
    )
        .environmentObject(FirebaseViewModel())
        .environmentObject(PlannerViewModel())
}
