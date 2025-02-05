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
    @EnvironmentObject private var plannerVM: PlannerViewModel
    
    @State private var title = ""
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var location = ""
    @State private var description = ""
    @State private var color = 0
    
    @State private var currentDetent:Set<PresentationDetent> = [.fraction(0.07)]
    @State private var selectedDetent: PresentationDetent = .fraction(0.07)
    @State private var addSchedule = false  //  스케줄 버튼 탭 여부
    @State private var tapStartTime = false //  시작 시간 탭 여부
    @State private var tapEndTime = false   //  종료 시간 탭 여부
    @State private var tapStartDate = false //  시작 날짜 탭 여부
    @State private var tapEndDate = false   //  종료 날짜 탭
    @State private var allDay = false       //  종일 여부
    @State private var tapRepeat = false    //  반복 탭 여부
    @State private var tapLocation = false  //  위치 탭 여부
    @State private var descriptionFocus = false   //  설명 탭 여부
    @State private var descriptionHeight = CGFloat(17)  //  설명 높이
    @State private var tapColor = false  //  색상 탭 여부
    @FocusState private var titleFocus: Bool
    
    init(schedule: Binding<ScheduleData?>) {
        self._schedule = schedule
        
        if schedule.wrappedValue != nil { // Binding 내부 값 확인
            self._startTime = State(initialValue: schedule.wrappedValue!.timeLine.0)
            self._endTime = State(initialValue: schedule.wrappedValue!.timeLine.1)
            self._title = State(initialValue: schedule.wrappedValue!.title)
            self._location = State(initialValue: schedule.wrappedValue!.location)
            self._description = State(initialValue: schedule.wrappedValue!.description)
            self._color = State(initialValue: schedule.wrappedValue!.color)
        }
    }
    
    var body: some View {
        VStack {
            if !addSchedule {
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
                                currentDetent = currentDetent.union([.fraction(0.07)])
                                selectedDetent = .fraction(0.07)
                                DispatchQueue.main.async {
                                    currentDetent = currentDetent.subtracting([.large, .fraction(0.4)])
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
                            if schedule != nil {
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "ellipsis")
                                        .foregroundStyle(Color.gray)
                                        .font(.system(size: 30))
                                }
                            }
                            Button(action: {
                                addSchedule = false
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
                    ScrollView {
                        VStack(alignment: .leading) {
                            TextField("제목", text: $title)
                                .font(.headline)
                                .focused($titleFocus)
                                .textSelection(.enabled)
                            Divider()
                                .padding(.vertical)
                            HStack(alignment: .top) {
                                Image(systemName: "clock")
                                    .foregroundStyle(Color.gray)
                                    .frame(width: 25)
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 0) {
                                        Text(plannerVM.getDateString(for: startTime, components: [.hour, .minute]))
                                            .foregroundStyle(tapStartTime ? Color.blue : Color.primary)
                                            .onTapGesture {
                                                tapStartTime.toggle()
                                                tapEndTime = false
                                            }
                                            .frame(width: screenWidth / 4, alignment: .leading)
                                        Image(systemName: "arrow.right")
                                            .foregroundStyle(Color.gray)
                                            .frame(width: screenWidth / 10, alignment: .leading)
                                        Text(plannerVM.getDateString(for: endTime, components: [.hour, .minute]))
                                            .foregroundStyle(tapEndTime ? Color.blue : Color.primary)
                                            .onTapGesture {
                                                tapEndTime.toggle()
                                                tapStartTime = false
                                            }
                                    }
                                    HStack(spacing: 0) {
                                        Text(
                                            plannerVM.getDateString(for: startTime, components: [.month, .day])
                                        )
                                        .foregroundStyle(tapStartDate ? Color.blue : Color.primary)
                                        .onTapGesture {
                                            tapStartDate.toggle()
                                            tapEndDate = false
                                        }
                                        .frame(width: screenWidth / 4 + screenWidth / 10, alignment: .leading)
                                        if !plannerVM.isSameDate(date1: startTime, date2: endTime, components: [.year, .month, .day]) {
                                            Text(
                                                plannerVM.getDateString(for: endTime, components: [.month, .day])
                                            )
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
                                    Image(systemName: "photo")
                                        .frame(width: 25)
                                        .foregroundStyle(Color.gray)
                                    Text("사진")
                                        .foregroundStyle(Color.gray)    //  이미지가 있다면
                                }
                                HStack {
                                    Image(systemName: "map")
                                        .frame(width: 25)
                                        .foregroundStyle(Color.gray)
                                    if location.isEmpty {
                                        Text("위치")  //  NavigationStack 구현 예정
                                            .foregroundStyle(Color.gray)
                                    }
                                    else {
                                        Text(location)
                                    }
                                }
                            }
                            Divider()
                                .padding(.vertical)
                            UIKitTextEditor(
                                text: $description,
                                isFocused: $descriptionFocus,
                                minHeight: $descriptionHeight,
                                placeholder: "설명"
                            )
                            .frame(height: descriptionHeight)
                            Divider()
                                .padding(.vertical)
                        }
                    }
                    .scrollDisabled(!titleFocus) // 키보드가 내려가면 스크롤 비활성화
                    Spacer()
                }
                .onAppear {
                    if schedule == nil {
                        startTime = plannerVM.mergedDate
                        endTime = startTime.addingTimeInterval(1800)
                    }
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
                        selectedTime: $startTime,
                        component: .hourAndMinute
                    )
                    .onChange(of: startTime) { value in
                        if startTime > endTime {
                            endTime = startTime.addingTimeInterval(1800)
                        }
                    }
                }
                .sheet(isPresented: $tapEndTime) {
                    DateTimePicker(
                        selectedTime: $endTime,
                        component: .hourAndMinute
                    )
                    .onChange(of: endTime) { value in
                        if endTime < startTime {
                            startTime = endTime
                        }
                    }
                }
                .sheet(isPresented: $tapStartDate) {
                    DateTimePicker(
                        selectedTime: $plannerVM.selectDate,
                        component: .date,
                        style: .graphical
                    )
                }
                .sheet(isPresented: $tapRepeat) {
                    ScheduleCycleView(schedule: $schedule)
                        .environmentObject(plannerVM)
                }
            }
        }
        .padding()
        .presentationDetents(currentDetent, selection: $selectedDetent)
    }
}

#Preview {
    ScheduleView(
        schedule: .constant(nil)
    )
    .environmentObject(PlannerViewModel())
}
