//
//  TimeLineView.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//

import SwiftUI
import FirebaseFirestore

struct TimeLineView: View {
    @EnvironmentObject private var plannerVM: PlannerViewModel
    @EnvironmentObject private var firebaseVM: FirebaseViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var is12TimeFmt = true
    @State private var timeZoneSize = CGSizeZero
    @State private var selection = 0
    @State private var calendarData = [Date]()
    @State private var gap = UIScreen.main.bounds.width / 24    //  이거 조절해서 간격 조절
    @State private var lastGap = UIScreen.main.bounds.width / 24
    @State private var schedules = [ScheduleData]()
    let screenWidth = UIScreen.main.bounds.width
    
    init() {

    }
    
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
                        Text(plannerVM.dateString(date: plannerVM.selectDate, component: .day))
                            .font(.callout)
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    plannerVM.isSameDate(
                                        date1: plannerVM.selectDate,
                                        date2: plannerVM.today,
                                        components: [.year, .month, .day]) ? Color.timeBar : Color.gray.opacity(0.5)
                                )
                                .frame(width: screenWidth / 14, height: screenWidth / 14)
                            Text("\(DateFormatter.krWeekDay.string(from: plannerVM.selectDate))")
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
                                        let hours = plannerVM.getHours(is12hoursFmt: is12TimeFmt)
                                        ForEach(Array(zip(hours.indices, hours)), id: \.1.id) { index, hour in
                                            Text("\(hour.timePeriod) \(hour.time)")
                                                .font(.caption)
                                                .foregroundStyle(Color.gray)
                                                .opacity(
                                                    plannerVM.isCollapsed(
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
                                        plannerVM.getDateString(
                                            for: plannerVM.today,
                                            components: [.hour, .minute],
                                            is12hoursFmt: is12TimeFmt
                                        )
                                    )
                                        .font(.caption)
                                        .padding(.trailing, 2)
                                        .offset(y: plannerVM.getOffsetFromMiniute(
                                            for: plannerVM.today,
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
                                                        Divider()
                                                        Spacer()
                                                            .onTapGesture { //  [현재시간, 현재시간 + 30분]
                                                                
                                                            }
                                                    }
                                                    .frame(height: timeZoneSize.height)
                                                }
                                            }
                                            
                                            //  스케줄 목록을 표시하는 ScheduleBox
                                            ForEach(Array(zip(schedules.indices, schedules)), id: \.1.id) { idx, schedule in
                                                let (startOffset, boxHeight) = plannerVM.getTimeBoxOffset(
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
                                                showVerticalLine: plannerVM.isSameDate(
                                                    date1: date,
                                                    date2: plannerVM.today,
                                                    components: [.year, .month, .day])
                                            )
                                            .id(UUID())
                                            .padding(
                                                .leading, plannerVM.isSameDate(
                                                    date1: date,
                                                    date2: plannerVM.today,
                                                    components: [.year, .month, .day]) ? 2 : 0
                                            )
                                            .offset(y: plannerVM.getOffsetFromMiniute(
                                                for: plannerVM.today,
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
//                                .simultaneousGesture(
//                                    MagnificationGesture()    //  줌 효과 -> 수정 필요
//                                        .onChanged { value in   // min: 너무 커지지 않게, max: 너무 작아지지 않게
//                                            gap = min(screenWidth, max(lastGap * value, screenWidth / 24))
//                                        }
//                                        .onEnded { _ in
//                                            lastGap = max(gap, screenWidth / 24)
//                                        }
//                                )
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
                calendarData = plannerVM.calendarData[1]
                selection = calendarData.firstIndex(where: {
                   plannerVM.isSameDate(
                    date1: $0,
                    date2: plannerVM.selectDate,
                    components: [.year, .month, .day]) }
                )!
            }
            .onChange(of: selection) { value in
                withAnimation {
                    plannerVM.wasPast = plannerVM.selectDate < calendarData[value]
                    plannerVM.selectDate = calendarData[value]
                }
            }
            .onChange(of: plannerVM.selectDate) { value in
                withAnimation {
                    if !calendarData.contains(value) {
                        calendarData = plannerVM.calendarDates(date: value)
                    }
                    selection = calendarData.firstIndex(where: {
                        plannerVM.isSameDate(
                            date1: $0,
                            date2: value,
                            components: [.year, .month, .day]) }
                    )!
                }
            }
        }
        .onChange(of: is12TimeFmt) { value in
            firebaseVM.set12TimeFmt(timeFmt: value) { error in
                if let error = error {
                    print(error)
                }
                else {
                    print("정상적으로 12시간제 재저장")
                }
            }
        }
    }
}

#Preview {
    TimeLineView()
        .environmentObject(PlannerViewModel())
}
