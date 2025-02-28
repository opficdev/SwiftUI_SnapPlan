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
    @StateObject var scheduleVM = ScheduleViewModel()
    @StateObject var searchVM = SearchLocationViewModel()
    
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
                    .onDisappear {
                        if let schedule = schedule {
                            scheduleVM.setSchedule(schedule: schedule)
                        }
                        else {
                            let startDate = plannerVM.getMergedDate(
                                for: plannerVM.selectDate,
                                with: plannerVM.today,
                                forComponents: [.year, .month, .day],
                                withComponents: [.hour, .minute]
                            )
                            scheduleVM.setSchedule(startDate: startDate)
                        }
                    }
                }
                else {
                    VStack {
                        HStack {
                            Spacer()
                            if scheduleVM.title.isEmpty {
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
                                                await firebaseVM.loadScheduleData(date: scheduleVM.startDate)
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
                                    if let schedule = schedule, !schedule.title.isEmpty {
                                        Task {
                                            do {
                                                let newSchedule = scheduleVM.getSchedule()
                                                try await firebaseVM.modifyScheduleData(schedule: newSchedule)
                                                await firebaseVM.loadScheduleData(date: scheduleVM.startDate)
                                            } catch {
                                                print("스케줄 수정 실패: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                    else {
                                        Task {
                                            do {
                                                let schedule = scheduleVM.getSchedule()
                                                try await firebaseVM.addScheduleData(schedule: schedule)
                                                await firebaseVM.loadScheduleData(date: scheduleVM.startDate)
                                            } catch {
                                                print("스케줄 추가 실패: \(error.localizedDescription)")
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
                                UIKitTextEditor(text: $scheduleVM.title, isFocused: $titleFocus, placeholder: "제목", font: .title2)
                                    .textSelection(.enabled)
                                Divider()
                                    .padding(.vertical)
                                HStack(alignment: .top) {
                                    Image(systemName: "clock")
                                        .foregroundStyle(Color.gray)
                                        .frame(width: 25)
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 0) {
                                            Text(plannerVM.getDateString(for: scheduleVM.startDate, components: [.hour, .minute]))
                                                .foregroundStyle(tapStartTime ? Color.blue : (scheduleVM.allDay ? Color.gray : Color.primary))
                                                .onTapGesture {
                                                    tapStartTime.toggle()
                                                    tapEndTime = false
                                                }
                                                .frame(width: screenWidth / 4, alignment: .leading)
                                                .disabled(scheduleVM.allDay)
                                            Image(systemName: "arrow.right")
                                                .foregroundStyle(Color.gray)
                                                .frame(width: screenWidth / 10, alignment: .leading)
                                            Text(plannerVM.getDateString(for: scheduleVM.endDate, components: [.hour, .minute]))
                                                .foregroundStyle(tapEndTime ? Color.blue : (scheduleVM.allDay ? Color.gray : Color.primary))
                                                .onTapGesture {
                                                    tapEndTime.toggle()
                                                    tapStartTime = false
                                                }
                                                .disabled(scheduleVM.allDay)
                                        }
                                        HStack(spacing: 0) {
                                            Text(plannerVM.getDateString(for: scheduleVM.startDate, components: [.month, .day]))
                                                .foregroundStyle(tapStartDate ? Color.blue : Color.primary)
                                                .onTapGesture {
                                                    tapStartDate.toggle()
                                                    tapEndDate = false
                                                }
                                                .frame(width: screenWidth / 4 + screenWidth / 10, alignment: .leading)
                                            if !plannerVM.isSameDate(date1: scheduleVM.startDate, date2: scheduleVM.endDate, components: [.year, .month, .day]) || scheduleVM.allDay {
                                                Text(plannerVM.getDateString(for: scheduleVM.endDate, components: [.month, .day]))
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
                                    Toggle("종일", isOn: $scheduleVM.allDay)
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
                                            ColorSelector(color: $scheduleVM.color)
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
                                        // NavigationLink 내 뷰일 경우 selectedDetent를 .large로 고정해야함
                                        NavigationLink(destination: LocationView) {
                                            Text(scheduleVM.location.isEmpty ? "위치" : scheduleVM.location)
                                                .foregroundStyle(scheduleVM.location.isEmpty ? Color.gray : Color.primary)
                                                .underline(!scheduleVM.location.isEmpty)
                                        }
                                        .navigationTitle("")
                                        Spacer()
                                        if !scheduleVM.location.isEmpty {
                                            NavigationLink(destination: SearchLocationView().environmentObject(scheduleVM).environmentObject(searchVM)) {
                                                Image(systemName: "pencil")
                                                    .foregroundStyle(Color.gray)
                                                    .bold()
                                            }
                                            .navigationTitle("")
                                        }
                                    }
                                }
                                Divider()
                                    .padding(.vertical)
                                UIKitTextEditor(text: $scheduleVM.description, isFocused: $descriptionFocus, placeholder: "설명")
                                Divider()
                                    .padding(.vertical)
                            }
                        }
                        .scrollDisabled(!(titleFocus || descriptionFocus)) // 키보드가 내려가면 스크롤 비활성화
                        Spacer()
                    }
                    .onChange(of: scheduleVM.startDate) { date in
                        scheduleVM.endDate = plannerVM.getMergedDate(
                            for: scheduleVM.startDate,
                            with: scheduleVM.endDate,
                            forComponents: [.year, .month, .day],
                            withComponents: [.hour, .minute]
                        )
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
                            selectedTime: $scheduleVM.startDate,
                            component: .hourAndMinute
                        )
                    }
                    .sheet(isPresented: $tapEndTime) {
                        DateTimePicker(
                            selectedTime: $scheduleVM.endDate,
                            component: .hourAndMinute
                        )
                    }
                    .sheet(isPresented: $tapStartDate) {
                        DateTimePicker(
                            selectedTime: $scheduleVM.startDate,
                            component: .date,
                            style: .graphical
                        )
                    }
                    .sheet(isPresented: $tapEndDate) {
                        DateTimePicker(
                            selectedTime: $scheduleVM.endDate,
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
                                    await firebaseVM.loadScheduleData(date: scheduleVM.startDate)
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
                if let _ = value {
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
            .onChange(of: scheduleVM.startDate) { date in
                if scheduleVM.endDate < date {
                    if scheduleVM.allDay {
                        scheduleVM.endDate = plannerVM.getMergedDate(for: date, with: scheduleVM.endDate, forComponents: [.year, .month, .day], withComponents: [.hour, .minute])
                    }
                    else {
                        scheduleVM.endDate = date.addingTimeInterval(1800)
                    }
                }
            }
            .onChange(of: scheduleVM.endDate) { date in
                if date < scheduleVM.startDate {
                    if scheduleVM.allDay {
                        scheduleVM.startDate = plannerVM.getMergedDate(for: date, with: scheduleVM.startDate, forComponents: [.year, .month, .day], withComponents: [.hour, .minute])
                    }
                    else {
                        scheduleVM.startDate = date.addingTimeInterval(-1800)
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
    
    @ViewBuilder
    private var LocationView: some View {
        if scheduleVM.location.isEmpty {
            SearchLocationView()
                .environmentObject(scheduleVM)
                .environmentObject(searchVM)
        }
        else {
            MapView()
                .environmentObject(scheduleVM)
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
