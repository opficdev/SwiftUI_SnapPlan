//
//  ScheduleView.swift
//  SnapPlan
//
//  Created by opfic on 1/17/25.
//
//  MARK: 메인 뷰에서 sheet에 올라오는 뷰

import SwiftUI

struct ScheduleView: View {
    let colorArr = [
        Color.macBlue, Color.macPurple, Color.macPink, Color.macRed,
        Color.macOrange, Color.macYellow, Color.macGreen
    ]
    let screenWidth = UIScreen.main.bounds.width
    @Binding var schedule: ScheduleData?
    @EnvironmentObject var plannerVM: PlannerViewModel
    @EnvironmentObject var firebaseVM: FirebaseViewModel
    @EnvironmentObject var uiVM: UIViewModel
    
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var allDay = false
    @State private var cycleOption = ScheduleData.CycleOption.none
    @State private var location = ""
    @State private var description = ""
    @State private var color = 0
    
    @State private var currentDetent:Set<PresentationDetent> = [.fraction(0.07)]
    @State private var selectedDetent: PresentationDetent = .fraction(0.07)
    @State private var addSchedule = false  //  스케줄 버튼 탭 여부
    @State private var tapStartTime = false //  시작 시간 탭 여부
    @State private var tapStartDate = false //  시작 날짜 탭 여부
    @State private var tapEndTime = false   //  종료 시간 탭 여부
    @State private var tapEndDate = false   //  종료 시간 탭 여부
    @State private var tapRepeat = false    //  반복 탭 여부
    @State private var tapLocation = false  //  위치 탭 여부
    @State private var tapColor = false  //  색상 탭 여부
    @State private var tapDeleteSchedule = false   //  스케줄 삭제 탭 여부
    @State private var sheetMinHeight = CGFloat.zero //    sheet 최소 높이
    
    @State private var titleFocus = false    //  제목 포커싱 여부
    @State private var descriptionFocus = false   //  설명 포커싱 여부
    
    var body: some View {
        NavigationStack {
            VStack {
                if !addSchedule && schedule == nil {
                    HStack {
                        Text("선택된 이벤트 없음")
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                            .padding(.leading)
                        Spacer()
                        Button(action: {
                            addSchedule = true
                            titleFocus = true
                            currentDetent = currentDetent.union([.large])
                            selectedDetent = .large
                            DispatchQueue.main.async {
                                currentDetent = currentDetent.subtracting([.fraction(0.07)])
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.white, Color.gray.opacity(0.2))
                                .font(.system(size: 30))
                        }
                    }
                }
                else {
                    VStack {
                        HStack {
                            Spacer()
                            if title.isEmpty {
                                Button(action: {
                                    addSchedule = false
                                    titleFocus = false
                                    descriptionFocus = false
                                    if schedule == nil {
                                        currentDetent = currentDetent.union([.fraction(0.07)])
                                        selectedDetent = .fraction(0.07)
                                        DispatchQueue.main.async {
                                            currentDetent = currentDetent.subtracting([.large, .fraction(0.4)])
                                        }
                                    }
                                    else {
                                        schedule = nil  //  schedule이 nil이 아님에서 nil이 되었으므로 onChange(of: schedule) 실행
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(Color.white, Color.gray.opacity(0.2))
                                        .font(.system(size: 30))
                                        .rotationEffect(.degrees(45))
                                }
                            }
                            else {
                                if let schedule = schedule {
                                    Menu(content: {
                                        Button(action: {
                                            titleFocus = false
                                            descriptionFocus = false
                                            addSchedule = false
                                            self.schedule = nil
                                        }) {
                                            Label("취소", systemImage: "xmark")
                                        }
                                        Button(action: {
                                            let copy = ScheduleData(
                                                title: schedule.title,
                                                timeLine: (schedule.timeLine.0.addingTimeInterval(3600), schedule.timeLine.1.addingTimeInterval(3600)),
                                                location: schedule.location,
                                                description: schedule.description,
                                                color: schedule.color
                                            )
                                            Task {
                                                try await firebaseVM.addScheduleData(schedule: copy)
                                                await firebaseVM.loadScheduleData(date: startDate)
                                            }
                                        }) {
                                            Label("복제", systemImage: "doc.on.doc")
                                        }
                                        Button(role: .destructive, action: {
                                            tapDeleteSchedule = true
                                        }) {
                                            Label("삭제", systemImage: "trash")
                                        }
                                    }) {
                                        Image(systemName: "ellipsis")
                                            .font(.system(size: 20))
                                            .foregroundStyle(Color.gray)
                                            .padding()
                                    }
                                }
                                Button(action: {
                                    if var schedule = schedule, !schedule.title.isEmpty {
                                        Task {
                                            do {
                                                schedule.title = title
                                                schedule.timeLine = (startDate, endDate)
                                                schedule.allDay = allDay
                                                schedule.cycleOption = cycleOption
                                                schedule.location = location
                                                schedule.description = description
                                                schedule.color = color
                                                try await firebaseVM.modifyScheduleData(schedule: schedule)
                                                await firebaseVM.loadScheduleData(date: startDate)
                                            } catch {
                                                print("스케줄 수정 실패: \(error)")
                                            }
                                        }
                                    }
                                    else {
                                        Task {
                                            do {
                                                let schedule = ScheduleData(
                                                    title: title,
                                                    timeLine: (startDate, endDate),
                                                    allDay: allDay,
                                                    cycleOption: cycleOption,
                                                    location: location,
                                                    description: description,
                                                    color: color
                                                )
                                                try await firebaseVM.addScheduleData(schedule: schedule)
                                                await firebaseVM.loadScheduleData(date: startDate)
                                            } catch {
                                                print("스케줄 추가 실패: \(error)")
                                            }
                                        }
                                    }
                                    addSchedule = false
                                    titleFocus = false
                                    descriptionFocus = false
                                    schedule = nil
                                    currentDetent = currentDetent.union([.fraction(0.07)])
                                    selectedDetent = .fraction(0.07)
                                    DispatchQueue.main.async {
                                        currentDetent = currentDetent.subtracting([.large, .fraction(0.4)])
                                    }
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 40, height: 30)
                                        Text("완료")
                                            .foregroundStyle(Color.white)
                                    }
                                }
                            }
                        }
                        .frame(height: 30)
                        ScrollView {
                            VStack(alignment: .leading) {
                                UIKitTextEditor(text: $title, isFocused: $titleFocus, placeholder: "제목", font: .title2)
                                    .textSelection(.enabled)
                                Divider()
                                    .padding(.vertical)
                                HStack(alignment: .top) {
                                    Image(systemName: "clock")
                                        .foregroundStyle(Color.gray)
                                        .frame(width: 25)
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 0) {
                                            Text(plannerVM.getDateString(for: startDate, components: [.hour, .minute]))
                                                .foregroundStyle(tapStartTime ? Color.blue : (allDay ? Color.gray : Color.primary))
                                                .onTapGesture {
                                                    tapStartTime.toggle()
                                                    tapEndTime = false
                                                }
                                                .frame(width: screenWidth / 4, alignment: .leading)
                                                .disabled(allDay)
                                            Image(systemName: "arrow.right")
                                                .foregroundStyle(Color.gray)
                                                .frame(width: screenWidth / 10, alignment: .leading)
                                            Text(plannerVM.getDateString(for: endDate, components: [.hour, .minute]))
                                                .foregroundStyle(tapEndTime ? Color.blue : (allDay ? Color.gray : Color.primary))
                                                .onTapGesture {
                                                    tapEndTime.toggle()
                                                    tapStartTime = false
                                                }
                                                .disabled(allDay)
                                        }
                                        HStack(spacing: 0) {
                                            Text(plannerVM.getDateString(for: startDate, components: [.month, .day]))
                                                .foregroundStyle(tapStartDate ? Color.blue : Color.primary)
                                                .onTapGesture {
                                                    tapStartDate.toggle()
                                                    tapEndDate = false
                                                }
                                                .frame(width: screenWidth / 4 + screenWidth / 10, alignment: .leading)
                                            if !plannerVM.isSameDate(date1: startDate, date2: endDate, components: [.year, .month, .day]) || allDay {
                                                Text(plannerVM.getDateString(for: endDate, components: [.month, .day]))
                                                    .foregroundStyle(tapEndDate ? Color.blue : Color.primary)
                                                    .onTapGesture {
                                                        tapEndDate.toggle()
                                                        tapStartDate = false
                                                    }
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                HStack {
                                    Image(systemName: "sun.max")
                                        .foregroundStyle(Color.gray)
                                        .frame(width: 25)
                                    Toggle("종일", isOn: $allDay)
                                        .toggleStyle(SwitchToggleStyle(tint: Color.blue))
                                        .frame(width: screenWidth / 4)
                                }
                                HStack {
                                    Image(systemName: "repeat")
                                        .foregroundStyle(Color.gray)
                                        .frame(width: 25)
                                    Text("반복")
                                        .foregroundStyle(tapRepeat ? Color.blue : Color.primary)
                                        .onTapGesture {
                                            tapRepeat.toggle()
                                        }
                                }
                                Divider()
                                    .padding(.vertical)
                                HStack {
                                    Image(systemName: "paintpalette")
                                        .frame(width: 25)
                                        .foregroundStyle(Color.gray)
                                    Text("색상")
                                        .onTapGesture {
                                            tapColor.toggle()
                                        }
                                        .sheet(isPresented: $tapColor) {
                                            ColorSelector(color: $color)
                                        }
                                }
                                Divider()
                                    .padding(.vertical)
                                VStack(alignment:. leading, spacing: 20) {
                                    HStack {
                                        Image(systemName: "memories.badge.plus")
                                            .frame(width: 25)
                                            .foregroundStyle(Color.gray)
                                        Text("음성 메모")
                                            .foregroundStyle(Color.gray)
                                    }
                                    HStack {
                                        Image(systemName: "photo")
                                            .frame(width: 25)
                                            .foregroundStyle(Color.gray)
                                        Text("사진")
                                            .foregroundStyle(Color.gray)
                                    }
                                    HStack {
                                        Image(systemName: "map")
                                            .frame(width: 25)
                                            .foregroundStyle(Color.gray)
                                        NavigationLink(destination: MapView(location: $location)) {
                                            Text(location.isEmpty ? "위치" : location)
                                                .foregroundStyle(location.isEmpty ? Color.gray : Color.primary)
                                        }
                                    }
                                }
                                Divider()
                                    .padding(.vertical)
                                UIKitTextEditor(text: $description, isFocused: $descriptionFocus, placeholder: "설명")
                                Divider()
                                    .padding(.vertical)
                            }
                        }
                        .scrollDisabled(!(titleFocus || descriptionFocus)) // 키보드가 내려가면 스크롤 비활성화
                        Spacer()
                    }
                    .onAppear {
                        if let schedule = schedule {
                            title = schedule.title
                            startDate = schedule.timeLine.0
                            endDate = schedule.timeLine.1
                            allDay = schedule.allDay
                            location = schedule.location
                            description = schedule.description
                            color = schedule.color
                        }
                        else {
                            title = ""
                            startDate = plannerVM.getMergedDate(
                                for: plannerVM.selectDate,
                                with: plannerVM.today,
                                forComponents: [.year, .month, .day],
                                withComponents: [.hour, .minute]
                            )
                            endDate = startDate.addingTimeInterval(1800)
                            allDay = false
                            location = ""
                            description = ""
                            color = 0
                        }
                    }
                    .onChange(of: startDate) { date in
                        schedule?.timeLine.0 = date
                        endDate = plannerVM.getMergedDate(
                            for: startDate,
                            with: endDate,
                            forComponents: [.year, .month, .day],
                            withComponents: [.hour, .minute]
                        )
                    }
                    .onChange(of: endDate) { date in
                        schedule?.timeLine.1 = date
                    }
                    .onTapGesture {
                        if titleFocus {
                            titleFocus = false
                            currentDetent = [.large, .fraction(0.4)]
                        }
                        descriptionFocus = false
                    }
                    .sheet(isPresented: $tapStartTime) {
                        DateTimePicker(
                            selectedTime: $startDate,
                            component: .hourAndMinute
                        )
                    }
                    .sheet(isPresented: $tapEndTime) {
                        DateTimePicker(
                            selectedTime: $endDate,
                            component: .hourAndMinute
                        )
                    }
                    .sheet(isPresented: $tapStartDate) {
                        DateTimePicker(
                            selectedTime: $startDate,
                            component: .date,
                            style: .graphical
                        )
                    }
                    .sheet(isPresented: $tapEndDate) {
                        DateTimePicker(
                            selectedTime: $endDate,
                            component: .date,
                            style: .graphical
                        )
                    }
                    .sheet(isPresented: $tapRepeat) {
                        CycleOptionView(schedule: $schedule)
                            .environmentObject(plannerVM)
                    }
                    .confirmationDialog("스케줄을 삭제하시겠습니까?", isPresented: $tapDeleteSchedule, titleVisibility: .visible) {
                        Button(role: .destructive, action: {
                            addSchedule = false
                            titleFocus = false
                            descriptionFocus = false
                            Task {
                                do {
                                    defer { //  firebase에서 오류가 나도 실행
                                        schedule = nil
                                    }
                                    try await firebaseVM.deleteScheduleData(schedule: schedule!)
                                    await firebaseVM.loadScheduleData(date: startDate)
                                    schedule = nil
                                }
                            }
                        }) {
                            Text("삭제")
                        }
                        Button(role: .cancel, action: {
                            
                        }) {
                            Text("취소")
                        }
                    }
                }
            }
            .padding()
            .presentationDetents(currentDetent, selection: $selectedDetent)
            .onChange(of: schedule) { value in
                if let schedule = value {
                    startDate = schedule.timeLine.0
                    endDate = schedule.timeLine.1
                    currentDetent = currentDetent.union([.large, .fraction(0.4)])
                    selectedDetent = .fraction(0.4)
                    DispatchQueue.main.async {
                        currentDetent = currentDetent.subtracting([.fraction(0.07)])
                    }
                }
                else {
                    currentDetent = currentDetent.union([.fraction(0.07)])
                    selectedDetent = .fraction(0.07)
                    DispatchQueue.main.async {
                        currentDetent = currentDetent.subtracting([.large, .fraction(0.4)])
                    }
                }
            }
            .onChange(of: startDate) { date in
                if endDate < date {
                    if allDay {
                        endDate = plannerVM.getMergedDate(for: date, with: endDate, forComponents: [.year, .month, .day], withComponents: [.hour, .minute])
                    }
                    else {
                        endDate = date.addingTimeInterval(1800)
                    }
                }
            }
            .onChange(of: endDate) { date in
                if date < startDate {
                    if allDay {
                        startDate = plannerVM.getMergedDate(for: date, with: startDate, forComponents: [.year, .month, .day], withComponents: [.hour, .minute])
                    }
                    else {
                        startDate = date.addingTimeInterval(-1800)
                    }
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.clear.onChange(of: proxy.size.height) { height in
                        if selectedDetent != .large {
                            DispatchQueue.main.async {
                                uiVM.sheetPadding = height
                            }
                        }
                    }
                }
                    .ignoresSafeArea(.all, edges: .bottom)
            )
        }
    }
}

#Preview {
    ScheduleView(
        schedule: .constant(
            ScheduleData(
                title: "Test Title",
                timeLine: (Date(), Date().addingTimeInterval(1800)),
                location: "Test Location",
                description: "Test Description",
                color: 0
            )
        )
    )
    .environmentObject(PlannerViewModel())
    .environmentObject(FirebaseViewModel())
    .environmentObject(UIViewModel())
}
