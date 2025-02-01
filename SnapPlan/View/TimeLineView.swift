//
//  TimeLineView.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//

import SwiftUI

struct TimeLineView: View {
    @EnvironmentObject private var viewModel: PlannerViewModel
    @Environment(\.colorScheme) var colorScheme
    let screenWidth = UIScreen.main.bounds.width
    @Binding var didSelectSchedule: Bool
        
    @State private var is12TimeFmt = true  // firebase에 저장 및 가져와야함
    @State private var timeZoneSize = CGSizeZero
    @State private var selection = 0
    @State private var calendarData = [Date]()
    @State private var gap = UIScreen.main.bounds.width / 24    //  이거 조절해서 간격 조절
    @State private var lastGap = UIScreen.main.bounds.width / 24
    @State private var schedules = [ScheduleData]()
    
    var body: some View {
        ZStack {
            Color.timeLine.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(is12TimeFmt ? "12시간제" : "24시간제")
                        .frame(width: screenWidth / 7)
                        .font(.caption)
                        .onTapGesture {
                            is12TimeFmt.toggle()
                        }
                    
                    HStack {
                        Text(viewModel.dateString(date: viewModel.selectDate, component: .day))
                            .font(.callout)
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    viewModel.isSameDate(
                                        date1: viewModel.selectDate,
                                        date2: viewModel.today,
                                        components: [.year, .month, .day]) ? Color.timeBar : Color.gray.opacity(0.5)
                                )
                                .frame(width: screenWidth / 14, height: screenWidth / 14)
                            Text("\(DateFormatter.krWeekDay.string(from: viewModel.selectDate))")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white)
                        }
                    }
                    .frame(width: screenWidth * 6 / 7, height: screenWidth / 10)
                }
                .background(Color.calendar)
                
                ZStack(alignment: .leading) {
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
                                                    viewModel.isCollapsed(
                                                        timeZoneHeight: timeZoneSize.height,
                                                        gap: gap,
                                                        index: index) ? 0 : 1
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
                                    Text(
                                        viewModel.getHoursAndMiniute(
                                            for: viewModel.today, is12hoursFmt: is12TimeFmt
                                        )
                                    )
                                        .font(.caption)
                                        .padding(.trailing, 2)
                                        .offset(y: viewModel.getOffsetFromMiniute(
                                            for: viewModel.today,
                                            timeZoneHeight: timeZoneSize.height,
                                            gap: gap
                                        )
                                    )
                                }
                                
                                //  좌우로 드래그 가능한 TimeLine
                                TabView(selection: $selection) {
                                    ForEach(Array(zip(calendarData.indices, calendarData)), id: \.1) { idx, date in
                                        ZStack(alignment: .top) {
                                            VStack(spacing: gap) {
                                                ForEach(0...24, id: \.self) { index in
                                                    VStack {
                                                        Spacer()
                                                            .onTapGesture { //  [현재시간 - 30분, 현재시간]
                                                                
                                                            }
                                                        Rectangle()
                                                            .frame(height: 1)
                                                            .foregroundColor(Color.gray.opacity(0.5))
                                                        Spacer()
                                                            .onTapGesture { //  [현재시간, 현재시간 + 30분]
                                                                
                                                            }
                                                    }
                                                    .frame(height: timeZoneSize.height)
                                                }
                                            }
                                            
                                            //  스케줄 목록을 표시하는 ScheduleBox
                                            ForEach(Array(zip(schedules.indices, schedules)), id: \.1.id) { idx, schedule in
                                                let (startOffset, boxHeight) = viewModel.getTimeBoxOffset(
                                                    from: schedule,
                                                    timeZoneHeight: timeZoneSize.height,
                                                    gap: gap
                                                )
                                                ScheduleBox(
                                                    height: boxHeight,
                                                    isChanging: $schedules[idx].isChanging
                                                )
                                                .offset(y: timeZoneSize.height + startOffset)
                                                .onTapGesture {
                                                    didSelectSchedule.toggle()
                                                    if schedules[idx].isChanging {
                                                        schedules[idx].isChanging = false
                                                    }
                                                    else {
                                                        schedules.indices.forEach { schedules[$0].isChanging = false }
                                                        schedules[idx].isChanging = true
                                                    }
                                                    
                                                }
                                            }
                                            
                                            //  현 시간 표시하는 TimeBar
                                            TimeBar(
                                                height: timeZoneSize.height,
                                                showVerticalLine: viewModel.isSameDate(
                                                    date1: date,
                                                    date2: viewModel.today,
                                                    components: [.year, .month, .day])
                                            )
                                            .id(UUID())
                                            .padding(
                                                .leading, viewModel.isSameDate(
                                                    date1: date,
                                                    date2: viewModel.today,
                                                    components: [.year, .month, .day]) ? 2 : 0
                                            )
                                            .offset(y: viewModel.getOffsetFromMiniute(
                                                for: viewModel.today,
                                                timeZoneHeight: timeZoneSize.height,
                                                gap: gap)
                                            )
                                        }
                                        .tag(idx)
                                    }
                                    .frame(width: screenWidth - timeZoneSize.width)
                                    .background(
                                        HStack {
                                            Rectangle()
                                                .frame(width: 1)
                                                .foregroundStyle(Color.gray.opacity(0.5))
                                            Spacer()
                                        }
                                    )
                                }
                                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                                .simultaneousGesture(
                                    MagnificationGesture()
                                        .onChanged { value in   // min: 너무 커지지 않게, max: 너무 작아지지 않게
                                            gap = min(screenWidth, max(lastGap * value, screenWidth / 24))
                                        }
                                        .onEnded { _ in
                                            lastGap = max(gap, screenWidth / 24)
                                        }
                                )
                            }
                        }
                    }
                    Rectangle()
                        .frame(width: 1)
                        .foregroundStyle(Color.gray)
                        .offset(x: timeZoneSize.width)
                    
                }
                Rectangle()
                    .frame(width: 1, height: UIScreen.main.bounds.height * 0.07)
                    .foregroundStyle(Color.gray)
                    .offset(x: timeZoneSize.width)
            }
            .onAppear {
                calendarData = viewModel.calendarData[1]
                selection = calendarData.firstIndex(where: {
                   viewModel.isSameDate(
                    date1: $0,
                    date2: viewModel.selectDate,
                    components: [.year, .month, .day]) }
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
                        calendarData = viewModel.calendarDates(date: value)
                    }
                    selection = calendarData.firstIndex(where: {
                        viewModel.isSameDate(
                            date1: $0,
                            date2: value,
                            components: [.year, .month, .day]) }
                    )!
                }
            }
        }
    }
}

#Preview {
    TimeLineView(
        didSelectSchedule: .constant(false)
    )
        .environmentObject(PlannerViewModel())
}
