//
//  ScheduleView.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//

//  today가 업데이트 되었는데도 CurrentTimeBar의 핑크에서 그레이로 자동 변경되지 않는 현상 있음

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject private var viewModel: PlannerViewModel
    @Environment(\.colorScheme) var colorScheme
    let screenWidth = UIScreen.main.bounds.width
        
    @State private var is12TimeFmt = true  //  후에 firebase에 저장 및 가져와야함
    @State private var timeZoneSize = CGSizeZero
    @State private var gap: CGFloat = UIScreen.main.bounds.width / 24    //  이거 조절해서 간격 조절
    @State private var selection = 0
    @State private var calendarData = [Date]()
    
    var body: some View {
        ZStack {
            Color.scheduleBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(is12TimeFmt ? "12시간제" : "24시간제")
                        .frame(width: screenWidth / 7)
                        .font(.caption)
                        .onTapGesture {
                            is12TimeFmt.toggle()
                        }
                    
                    TabView(selection: $selection) {
                        ForEach(Array(zip(calendarData.indices, calendarData)), id: \.1) { idx, date in
                            HStack {
                                Text(viewModel.dateString(date: date, component: .day))
                                    .font(.callout)
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            viewModel.isSameDate(date1: date, date2: viewModel.today, components: [.year, .month, .day]) ? Color.pink : Color.gray.opacity(0.5)
                                        )
                                        .frame(width: screenWidth / 14, height: screenWidth / 14)
                                    Text("\(DateFormatter.krWeekDay.string(from: date))")
                                        .font(.callout)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                }
                            }
                            .tag(idx)
                        }
                        .frame(width: screenWidth - timeZoneSize.width, height: screenWidth / 10)
                    }
                    .frame(width: screenWidth - timeZoneSize.width, height: screenWidth / 10)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .background(Color.calendarBackground)
                
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        HStack(spacing: 0) {
                            ZStack(alignment: .topTrailing) {
                                VStack(alignment: .trailing, spacing: gap) {
                                    let hours = viewModel.getHours(is12hoursFmt: is12TimeFmt)
                                    ForEach(Array(zip(hours.indices, hours)), id: \.1.id) { index, hour in
                                        Text("\(hour.timePeriod) \(hour.time)")
                                            .font(.caption)
                                            .foregroundStyle(Color.gray)
                                            .opacity(
                                                viewModel.isCollapsed(timeZoneHeight: timeZoneSize.height, gap: gap, index: index) ? 0 : 1
                                            )
                                            .padding(.trailing, 2)
                                            .frame(width: screenWidth / 7, alignment: .trailing)
                                            .background(
                                                GeometryReader { geometry in
                                                    Color.clear.onAppear {
                                                        if timeZoneSize == CGSizeZero {
                                                            timeZoneSize = geometry.size
                                                        }
                                                    }
                                                }
                                            )
                                    }
                                }
                                .border(Color.gray.opacity(0.5))
                                Text(viewModel.getHoursAndMiniute(is12hoursFmt: is12TimeFmt))
                                    .font(.caption)
                                    .padding(.trailing, 2)
                                    .offset(y: (timeZoneSize.height + gap) * 24 * viewModel.getRatioToMiniute())
                            }
                            
                            TabView(selection: $selection) {
                                ForEach(Array(zip(calendarData.indices, calendarData)), id: \.1) { idx, date in
                                    ZStack(alignment: .top) {
                                        VStack(spacing: gap) {
                                            ForEach(0...24, id: \.self) { index in
                                                ZStack {
                                                    Rectangle()
                                                        .frame(height: 1)
                                                        .foregroundColor(Color.gray.opacity(0.5))
                                                }
                                                .frame(height: timeZoneSize.height)
                                            }
                                        }
                                        CurrentTimeBar(
                                            height: timeZoneSize.height,
                                            showVerticalLine: viewModel.isSameDate(date1: date, date2: viewModel.today, components: [.year, .month, .day])
                                        )
                                        .padding(
                                            .leading, viewModel.isSameDate(date1: date, date2: viewModel.today, components: [.year, .month, .day]) ? 2 : 0
                                        )
                                        .offset(y: (timeZoneSize.height + gap) * 24 * viewModel.getRatioToMiniute())
                                    }
                                    .tag(idx)
                                }
                                .border(Color.gray.opacity(0.5))
                                .frame(width: screenWidth - timeZoneSize.width)
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .border(Color.gray.opacity(0.5))
                        }
                        .id(0)
                    }
                    .onAppear {
                        proxy.scrollTo(0, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                calendarData = viewModel.calendarData[1]
                selection = calendarData.firstIndex(where: {
                   viewModel.isSameDate(date1: $0, date2: viewModel.selectDate, components: [.year, .month, .day]) }
                )!
            }
            .onChange(of: selection) { value in
                withAnimation {
                    viewModel.wasPast = viewModel.selectDate < calendarData[value]
                    viewModel.selectDate = calendarData[value]
                }
            }
            .onChange(of: viewModel.selectDate) { value in
                withAnimation {
                    if !calendarData.contains(value) {
                        for month in viewModel.calendarData {
                            if month.contains(value) {
                                calendarData = month
                                break
                            }
                        }
                    }
                    selection = calendarData.firstIndex(where: {
                        viewModel.isSameDate(date1: $0, date2: value, components: [.year, .month, .day]) }
                    )!
                }
            }
        }
    }
}

#Preview {
    ScheduleView()
        .environmentObject(PlannerViewModel())
}
