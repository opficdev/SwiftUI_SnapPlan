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
    @StateObject private var scheduleVM = ScheduleViewModel()
    @EnvironmentObject private var plannerVM: PlannerViewModel
    @EnvironmentObject private var firebaseVM: FirebaseViewModel
    @Environment(\.colorScheme) var colorScheme
    @Binding var showScheduleView: Bool
    @State private var timeZoneSize = CGSizeZero
    @State private var calendarData = [Date]()
    @State private var gap = UIScreen.main.bounds.width / 24    //  이거 조절해서 간격 조절
    @State private var lastGap = UIScreen.main.bounds.width / 24
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
                
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: uiVM.allDayPadding)
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
                                                                    timeZoneSize.width = max(timeZoneSize.width, geometry.size.width)
                                                                    timeZoneSize.height = max(timeZoneSize.height, geometry.size.height)
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
                                            .offset(y: plannerVM.getOffsetFromDate(
                                                for: plannerVM.today,
                                                timeZoneHeight: timeZoneSize.height,
                                                gap: gap)
                                            )
                                        }
                                        Rectangle()
                                            .fill(Color.clear)
                                            .frame(width: timeZoneSize.width, height: uiVM.sheetPadding)
                                    }
                                    
                                    //  좌우로 드래그 가능한 TimeLine
                                    ScrollViewReader { scrollProxy in
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            LazyHStack(spacing: 0) {
                                                ForEach(Array(zip(calendarData.indices, calendarData)), id: \.1) { idx, date in
                                                    HStack(spacing: 0) {
                                                        Rectangle()
                                                            .frame(width: 1)
                                                            .foregroundStyle(Color.gray.opacity(0.3))
                                                        VStack {
                                                            ZStack(alignment: .top) {
                                                                //  MARK: 시간 구분선
                                                                VStack(spacing: 0) {
                                                                    ForEach(0...24, id: \.self) { index in
                                                                        VStack(spacing: 0) {
                                                                            Rectangle()
                                                                                .fill(Color.timeLine)
                                                                                .frame(maxHeight: .infinity)
                                                                                .onTapGesture {
                                                                                    if scheduleVM.schedule == nil && 0 < index {
                                                                                        let endDate = plannerVM.getDateFromIndex(index: index)
                                                                                        let startDate = endDate.addingTimeInterval(-1800)
                                                                                        scheduleVM.schedule = ScheduleData(startDate: startDate, endDate: endDate, isChanging: true)
                                                                                    }
                                                                                }
                                                                            Divider()
                                                                            Rectangle()
                                                                                .fill(Color.timeLine)
                                                                                .frame(maxHeight: .infinity)
                                                                                .onTapGesture {
                                                                                    if scheduleVM.schedule == nil && index < 24{
                                                                                        let startDate = plannerVM.getDateFromIndex(index: index)
                                                                                        let endDate = startDate.addingTimeInterval(1800)
                                                                                        scheduleVM.schedule = ScheduleData(startDate: startDate, endDate: endDate, isChanging: true)
                                                                                    }
                                                                                }
                                                                        }
                                                                        .frame(height: timeZoneSize.height + gap)
                                                                    }
                                                                }
                                                                
                                                                //  MARK: 반복 일정
                                                                let cyecleSchedules = firebaseVM.schedules.values.filter { $0.cycleOption != .none }
                                                                ForEach(Array(zip(cyecleSchedules.indices, cyecleSchedules)), id: \.1.id) { idx, scheduleData in
                                                                    if (scheduleVM.id != scheduleData.id && !scheduleData.isAllDay) && scheduleVM.isCycleConfirm(date: date, schedule: scheduleData) {
                                                                        ScheduleBox(
                                                                            gap: gap,
                                                                            timeZoneHeight: timeZoneSize.height,
                                                                            isChanging: false,
                                                                            schedule: .constant(scheduleData)
                                                                        )
                                                                        .onTapGesture {
                                                                            scheduleVM.schedule = scheduleData
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                //  MARK: 반복, 종일 설정이 없는 일정
                                                                let schedules = uiVM.findSchedules(containing: date, in: firebaseVM.schedules)
                                                                ForEach(Array(zip(schedules.indices, schedules)), id: \.1.id) { idx, scheduleData in
                                                                    if scheduleVM.id != scheduleData.id && !scheduleData.isAllDay && scheduleData.cycleOption == .none {
                                                                        ScheduleBox(
                                                                            gap: gap,
                                                                            timeZoneHeight: timeZoneSize.height,
                                                                            isChanging: false,
                                                                            schedule: .constant(scheduleData)
                                                                        )
                                                                        .onTapGesture {
                                                                            scheduleVM.schedule = scheduleData
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                //  MARK: 현재 조작중인 스케줄
                                                                if scheduleVM.schedule != nil && !scheduleVM.isAllDay {
                                                                    ScheduleBox(
                                                                        gap: gap,
                                                                        timeZoneHeight: timeZoneSize.height,
                                                                        isChanging: true,
                                                                        schedule: $scheduleVM.schedule
                                                                    )
                                                                    .onTapGesture {
                                                                        scheduleVM.schedule = nil
                                                                    }
                                                                }
                                                                
                                                                //  MARK: 현 시간 표시하는 TimeBar
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
                                                                .offset(y: plannerVM.getOffsetFromDate(
                                                                    for: plannerVM.today,
                                                                    timeZoneHeight: timeZoneSize.height,
                                                                    gap: gap)
                                                                )
                                                            }
                                                            Rectangle()
                                                                .fill(Color.clear)
                                                                .frame(width: CGFloat(Int(screenWidth - timeZoneSize.width)), height: uiVM.sheetPadding)
                                                        }
                                                    }
                                                    .id(idx)
                                                    .background(
                                                        GeometryReader { geometryProxy in
                                                            //  오직 감시용으로만 사용할 것
                                                            //  단, 감시를 해도 코드 내부 모든 오토 스크롤 이벤트 종료 후 관찰을 지속할 것
                                                            Color.clear.onChange(of: geometryProxy.frame(in: .global)) { frame in
                                                                if plannerVM.dragByUser && plannerVM.timeLineSelection != idx &&
                                                                    timeZoneSize.width <= frame.midX && frame.midX <= screenWidth {
                                                                    plannerVM.timeLineSelection = idx
                                                                }
                                                                if Int(screenWidth) == Int(frame.maxX) {
                                                                    plannerVM.dragByUser = false
                                                                    if plannerVM.monthChange {
                                                                        plannerVM.monthChange = false
                                                                        DispatchQueue.main.async {
                                                                            scrollProxy.scrollTo(plannerVM.timeLineSelection, anchor: .top)
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    )
                                                }
                                                .frame(width: CGFloat(Int(screenWidth - timeZoneSize.width)))
                                            }
                                            .onAppear {
                                                calendarData = plannerVM.calendarData[1]
                                                DispatchQueue.main.async {
                                                    scrollProxy.scrollTo(plannerVM.timeLineSelection, anchor: .top)
                                                    uiVM.allDayPadding = timeZoneSize.height * 2
                                                }
                                            }
                                            .onChange(of: plannerVM.userTapped) { value in
                                                if value {
                                                    withAnimation(.easeInOut(duration: 0.2)) {
                                                        scrollProxy.scrollTo(plannerVM.timeLineSelection, anchor: .top)
                                                    }
                                                    plannerVM.userTapped = false
                                                }
                                            }
                                        }
                                        .frame(width: CGFloat(Int(screenWidth - timeZoneSize.width)))
                                        .scrollDisabled(scheduleVM.schedule != nil)
                                        .pagingEnabled()
                                    }
                                    .simultaneousGesture(
//                                        MagnificationGesture()    //  줌 효과 -> 수정 필요
//                                            .onChanged { value in   // min: 너무 커지지 않게, max: 너무 작아지지 않게
//                                                gap = min(screenWidth, max(lastGap * value, screenWidth / 24))
//                                            }
//                                            .onEnded { _ in
//                                                lastGap = max(gap, screenWidth / 24)
//                                            }
                                        DragGesture()
                                            .onChanged { _ in
                                                plannerVM.dragByUser = true
                                            }
                                    )
                                }
                            }
                        }
                    }
                    HStack(alignment:. top, spacing: 2) {
                        Text("종일")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                            .padding(.trailing, 2)
                            .frame(width: timeZoneSize.width, height: uiVM.allDayPadding, alignment: .trailing)
                        
                        VStack(spacing: 3) {
                            //  MARK: 종일 일정 부분
                            let todaySchedules = uiVM.findSchedules(containing: plannerVM.selectDate, in: firebaseVM.schedules).sorted(by: { $0.title < $1.title })
                            ForEach(Array(zip(todaySchedules.indices, todaySchedules)), id: \.1.id) { idx, scheduleData in
                                if scheduleData.isAllDay {
                                    if scheduleVM.id == scheduleData.id {
                                        AllDayScheduleBox(height: timeZoneSize.height, schedule: $scheduleVM.schedule)
                                            .onTapGesture {
                                                scheduleVM.schedule = nil
                                            }
                                    }
                                    else {
                                        AllDayScheduleBox(height: timeZoneSize.height, schedule: .constant(scheduleData))
                                            .onTapGesture {
                                                scheduleVM.schedule = scheduleData
                                            }
                                    }
                                }
                            }
                            .frame(height: timeZoneSize.height)
                        }
                        .frame(width: screenWidth * 6 / 7, height: uiVM.allDayPadding, alignment: .top)
                        .background(Color.timeLine) //  터치 이벤트
                        .onTapGesture {
                            if scheduleVM.schedule == nil {
                                let startDate = Calendar.current.startOfDay(for: plannerVM.selectDate).addingTimeInterval(60 * 60 * 12)
                                let endDate = startDate.addingTimeInterval(1800)
                                scheduleVM.schedule = ScheduleData(startDate: startDate, endDate: endDate, isAllDay: true)
                            }
                        }
                    }
                    .background(Color.timeLine)
                    .border(Color.gray.opacity(0.3))
                    .onChange(of: firebaseVM.schedules) { schedules in
                        uiVM.setAllDayPadding(date: plannerVM.selectDate, height: timeZoneSize.height, schedules: schedules)
                    }
                    Rectangle()
                        .frame(width: 1)
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .offset(x: timeZoneSize.width)
                }
               
            }
        }
        .onChange(of: plannerVM.selectDate) { date in
            if calendarData != plannerVM.calendarData[1] {
                calendarData = plannerVM.calendarData[1]
            }
            uiVM.setAllDayPadding(date: date, height: timeZoneSize.height, schedules: firebaseVM.schedules)
        }
        .onChange(of: calendarData) { month in
            Task {
                firebaseVM.schedules.removeAll()
                // MARK: 일정 우선
                try await firebaseVM.fetchSchedule(from: month.first!, to: month.last!)
                
                // MARK: 사진, 음성메모 후순위
                for schedule in firebaseVM.schedules.keys {
                    if let uuid = UUID(uuidString: schedule) {
                        // 두 개의 독립적인 Task 생성
                        let memoTask = Task {
                            do {
                                firebaseVM.schedules[schedule]?.memoState = .loading
                                if let id = scheduleVM.id, id == uuid {
                                    await MainActor.run {
                                        scheduleVM.memoState = .loading
                                    }
                                }
                                let memo = try await firebaseVM.fetchVoiceMemo(schedule: uuid)
                                await MainActor.run {
                                    if let id = scheduleVM.id, id == uuid {
                                        scheduleVM.voiceMemo = memo
                                        scheduleVM.memoState = .success
                                    }
                                }
                                firebaseVM.schedules[schedule]?.voiceMemo = memo
                                firebaseVM.schedules[schedule]?.memoState = .success
                            } catch {
                                if error.localizedDescription == "Object not found" {
                                    firebaseVM.schedules[schedule]?.memoState = .success
                                    if let id = scheduleVM.id, id == uuid {
                                        await MainActor.run {
                                            scheduleVM.memoState = .success
                                        }
                                    }
                                } else {
                                    firebaseVM.schedules[schedule]?.memoState = .error
                                    if let id = scheduleVM.id, id == uuid {
                                        await MainActor.run {
                                            scheduleVM.memoState = .error
                                        }
                                    }
                                }
                            }
                        }

                        let photosTask = Task {
                            do {
                                firebaseVM.schedules[schedule]?.photosState = .loading
                                if let id = scheduleVM.id, id == uuid {
                                    await MainActor.run {
                                        scheduleVM.photosState = .loading
                                    }
                                }
                                let photos = try await firebaseVM.fetchPhotos(schedule: uuid)
                                await MainActor.run {
                                    if let id = scheduleVM.id, id == uuid {
                                        scheduleVM.photos = photos
                                        scheduleVM.photosState = .success
                                    }
                                }
                                firebaseVM.schedules[schedule]?.photos = photos
                                firebaseVM.schedules[schedule]?.photosState = .success
                            } catch {
                                firebaseVM.schedules[schedule]?.photosState = .error
                                if let id = scheduleVM.id, id == uuid {
                                    await MainActor.run {
                                        scheduleVM.photosState = .error
                                    }
                                }
                            }
                        }
                        await memoTask.value
                        await photosTask.value
                    }
                }
            }
        }
        .onChange(of: firebaseVM.is12TimeFmt) { value in
            Task {
                do {
                    try await firebaseVM.updateTimeFormat(is12TimeFmt: value)
                } catch {
                    print("12시간제 변경 에러", error.localizedDescription)
                }
            }
        }
        .sheet(isPresented: $showScheduleView) {
            ScheduleView()
                .environmentObject(plannerVM)
                .environmentObject(firebaseVM)
                .environmentObject(uiVM)
                .environmentObject(scheduleVM)
                .presentationDetents(uiVM.currentDetent, selection: $uiVM.selectedDetent)
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
