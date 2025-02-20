//
//  TimeLineView.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//

import SwiftUI
import SwiftUIIntrospect

struct TimeLineView: View {
    @StateObject var uiVM = UIViewModel()
    @EnvironmentObject private var plannerVM: PlannerViewModel
    @EnvironmentObject private var firebaseVM: FirebaseViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var showScheduleView: Bool
    @State private var timeZoneSize = CGSizeZero
    @State private var selection = 0
    @State private var calendarData = [Date]()
    @State private var gap = UIScreen.main.bounds.width / 24    //  이거 조절해서 간격 조절
    @State private var lastGap = UIScreen.main.bounds.width / 24
    @State private var schedule: ScheduleData? = nil    //  현재 선택 또는 추가될 스케줄
    @State private var didScheduleAdd = false    //  FirebaseVM의 생성자에서 오늘 날짜의 스케줄을 불러왔는지 최초 확인
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            Color.timeLine.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(firebaseVM.is12TimeFmt ? "12시간제" : "24시간제")
                        .frame(width: screenWidth / 7)
                        .font(.caption)
                        .onTapGesture {
                            firebaseVM.is12TimeFmt.toggle()
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
                    VStack {
                        ScrollViewReader { proxy in
                            ScrollView(showsIndicators: false) {
                                HStack(spacing: 0) {
                                    VStack {
                                        ZStack(alignment: .topTrailing) {
                                            VStack(alignment: .trailing, spacing: gap) {
                                                let hours = plannerVM.getHours(is12hoursFmt: firebaseVM.is12TimeFmt)
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
                                                    is12hoursFmt: firebaseVM.is12TimeFmt
                                                )
                                            )
                                            .font(.caption)
                                            .padding(.trailing, 2)
                                            .offset(y: plannerVM.getOffsetFromMiniute(
                                                for: plannerVM.today,
                                                timeZoneHeight: timeZoneSize.height,
                                                gap: gap)
                                            )
                                        }
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: timeZoneSize.width, height: uiVM.bottomPadding)
                                    }
                                    
                                    //  좌우로 드래그 가능한 TimeLine
                                    TabView(selection: $selection) {
                                        ForEach(Array(zip(calendarData.indices, calendarData)), id: \.1) { idx, date in
                                            HStack(spacing: 0) {
                                                Rectangle()
                                                    .frame(width: 1)
                                                    .foregroundStyle(Color.gray.opacity(0.3))
                                                VStack {
                                                    ZStack(alignment: .top) {
                                                        VStack(spacing: 0) {
                                                            ForEach(0...24, id: \.self) { index in
                                                                VStack(spacing: 0) {
                                                                    Rectangle()
                                                                        .fill(Color.timeLine)
                                                                        .frame(maxHeight: .infinity)
                                                                        .onTapGesture {
                                                                            if schedule == nil && 0 < index {
                                                                                let endDate = plannerVM.getDateFromIndex(index: index)
                                                                                let beginDate = endDate.addingTimeInterval(-1800)
                                                                                schedule = ScheduleData(timeLine: (beginDate, endDate), isChanging: true)
                                                                            }
                                                                        }
                                                                    Divider()
                                                                    Rectangle()
                                                                        .fill(Color.timeLine)
                                                                        .frame(maxHeight: .infinity)
                                                                        .onTapGesture {
                                                                            if schedule == nil && index < 24{
                                                                                let beginDate = plannerVM.getDateFromIndex(index: index)
                                                                                let endDate = beginDate.addingTimeInterval(1800)
                                                                                schedule = ScheduleData(timeLine: (beginDate, endDate), isChanging: true)
                                                                            }
                                                                        }
                                                                }
                                                                .frame(height: timeZoneSize.height + gap)
                                                            }
                                                        }
                                                        
                                                        
                                                        let dateString = DateFormatter.yyyyMMdd.string(from: date)
                                                        if let _ = firebaseVM.schedules[dateString] {   //  저장된 스케줄 목록
                                                            ForEach(Array(zip(firebaseVM.schedules[dateString]!.indices, firebaseVM.schedules[dateString]!)), id: \.1.id) { idx, scheduleData in
                                                                if schedule?.id != scheduleData.id {
                                                                    let (startOffset, boxHeight) = plannerVM.getScheduleBoxOffset(
                                                                        from: scheduleData,
                                                                        timeZoneHeight: timeZoneSize.height,
                                                                        gap: gap
                                                                    )
                                                                    ScheduleBox(
                                                                        gap: gap,
                                                                        timeZoneHeight: timeZoneSize.height,
                                                                        height: boxHeight,
                                                                        isChanging: false,
                                                                        schedule: .constant(scheduleData)
                                                                    )
                                                                    .offset(y: startOffset + timeZoneSize.height / 2)
                                                                    .onTapGesture {
                                                                        schedule = scheduleData
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                        if schedule != nil {    //  현재 조작중인 스케줄
                                                            if plannerVM.isSameDate(date1: schedule!.timeLine.0, date2: date, components: [.year, .month, .day]) {
                                                                let (startOffset, boxHeight) = plannerVM.getScheduleBoxOffset(
                                                                    from: schedule!,
                                                                    timeZoneHeight: timeZoneSize.height,
                                                                    gap: gap
                                                                )
                                                                ScheduleBox(
                                                                    gap: gap,
                                                                    timeZoneHeight: timeZoneSize.height,
                                                                    height: boxHeight,
                                                                    isChanging: true,
                                                                    schedule: $schedule
                                                                )
                                                                .offset(y: startOffset + timeZoneSize.height / 2)
                                                                .onTapGesture {
                                                                    schedule = nil
                                                                }
                                                            }
                                                        }
                                                        
                                                        //  현 시간 표시하는 TimeBarx
                                                        TimeBar(
                                                            height: timeZoneSize.height,
                                                            showVerticalLine: plannerVM.isSameDate(
                                                                date1: date,
                                                                date2: plannerVM.today,
                                                                components: [.year, .month, .day])
                                                        )
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
                                                    Rectangle()
                                                        .fill(Color.clear)
                                                        .frame(width: screenWidth - timeZoneSize.width, height: uiVM.bottomPadding)
                                                }
                                            }
                                            .tag(idx)
                                        }
                                        .frame(width: screenWidth - timeZoneSize.width)
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
                    }
                    Rectangle()
                        .frame(width: 1)
                        .foregroundStyle(Color.gray)
                        .offset(x: timeZoneSize.width)
                }
               
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
                    plannerVM.currentDate = calendarData[value]
                }
                if selection == 0 || selection == calendarData.count - 1 {
                    calendarData = plannerVM.calendarData[1]
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
            .onChange(of: calendarData) { month in  //  onAppear가 없는 이유: calendarData는 빈 상태로 초기화되므로 뷰가 로딩되면 알아서 onChange가 실행됨
                Task {
                    if didScheduleAdd {
                        firebaseVM.schedules.removeAll()
                    }
                    for date in month {
                        await firebaseVM.loadScheduleData(date: date)
                    }
                    didScheduleAdd = true
                }
            }
        }
        .onChange(of: firebaseVM.is12TimeFmt) { value in
            Task {
                do {
                    try await firebaseVM.set12TimeFmt(timeFmt: value)
                } catch {
                    print("12시간제 변경 에러", error.localizedDescription)
                }
            }
        }
        .sheet(isPresented: $showScheduleView) {
            ScheduleView(schedule: $schedule)
                .environmentObject(plannerVM)
                .environmentObject(firebaseVM)
                .environmentObject(uiVM)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(true)   //  사용자가 임의로 sheet를 완전히 내리는 것을 방지
                .introspect(.sheet, on: .iOS(.v16, .v17, .v18)) { controller in //  sheet가 올라와있어도 하위 뷰에 터치가 가능하도록 해줌
                    if let sheet = controller as? UISheetPresentationController {
                        if let maxDetent = sheet.detents.max(by: { $0.identifier.rawValue < $1.identifier.rawValue }) {
                            sheet.largestUndimmedDetentIdentifier = maxDetent.identifier
                        }
                    }
                }
        }
    }
}

#Preview {
    TimeLineView(showScheduleView: .constant(true))
        .environmentObject(PlannerViewModel())
        .environmentObject(FirebaseViewModel())
}
