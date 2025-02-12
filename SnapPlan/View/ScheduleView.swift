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
    @State private var location = ""
    @State private var description = ""
    @State private var color = 0
    
    @State private var currentDetent:Set<PresentationDetent> = [.fraction(0.07)]
    @State private var selectedDetent: PresentationDetent = .fraction(0.07)
    @State private var addSchedule = false  //  스케줄 버튼 탭 여부
    @State private var tapstartDate = false //  시작 시간 탭 여부
    @State private var tapendDate = false   //  종료 시간 탭 여부
    @State private var tapStartDate = false //  시작 날짜 탭 여부
    @State private var tapEndDate = false   //  종료 날짜 탭
    @State private var allDay = false       //  종일 여부
    @State private var tapRepeat = false    //  반복 탭 여부
    @State private var tapLocation = false  //  위치 탭 여부
    @State private var descriptionFocus = false   //  설명 탭 여부
    @State private var tapColor = false  //  색상 탭 여부
    @State private var titleFocus = false    //  제목 탭 여부
    @State private var sheetMinHeight = CGFloat.zero //    sheet 최소 높이
    
    var body: some View {
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
                                titleFocus = false
                                descriptionFocus = false
                                currentDetent = currentDetent.union([.fraction(0.07)])
                                selectedDetent = .fraction(0.07)
                                DispatchQueue.main.async {
                                    currentDetent = currentDetent.subtracting([.large, .fraction(0.4)])
                                }
                                
                                Task {
                                    do {
                                        let schedule = ScheduleData(
                                            title: title,
                                            timeLine: (startDate, endDate),
                                            location: location,
                                            description: description,
                                            color: color
                                        )
                                        try await firebaseVM.addScheduleData(schedule: schedule)
                                    } catch {
                                        print("스케줄 추가 실패: \(error)")
                                    }
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
                            UIKitTextEditor(
                                text: $title,
                                isFocused: $titleFocus,
                                placeholder: "제목",
                                font: .title2
                            )
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
                                            .foregroundStyle(tapstartDate ? Color.blue : Color.primary)
                                            .onTapGesture {
                                                tapstartDate.toggle()
                                                tapendDate = false
                                            }
                                            .frame(width: screenWidth / 4, alignment: .leading)
                                        Image(systemName: "arrow.right")
                                            .foregroundStyle(Color.gray)
                                            .frame(width: screenWidth / 10, alignment: .leading)
                                        Text(plannerVM.getDateString(for: endDate, components: [.hour, .minute]))
                                            .foregroundStyle(tapendDate ? Color.blue : Color.primary)
                                            .onTapGesture {
                                                tapendDate.toggle()
                                                tapstartDate = false
                                            }
                                    }
                                    HStack(spacing: 0) {
                                        Text(
                                            plannerVM.getDateString(for: startDate, components: [.month, .day])
                                        )
                                        .foregroundStyle(tapStartDate ? Color.blue : Color.primary)
                                        .onTapGesture {
                                            tapStartDate.toggle()
                                            tapEndDate = false
                                        }
                                        .frame(width: screenWidth / 4 + screenWidth / 10, alignment: .leading)
                                        if !plannerVM.isSameDate(date1: startDate, date2: endDate, components: [.year, .month, .day]) {
                                            Text(
                                                plannerVM.getDateString(for: endDate, components: [.month, .day])
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
//                                HStack {
//                                    Image(systemName: "photo")
//                                        .frame(width: 25)
//                                        .foregroundStyle(Color.gray)
//                                    Text("사진")
//                                        .foregroundStyle(Color.gray)
//                                }
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
                                placeholder: "설명"
                            )
                            Divider()
                                .padding(.vertical)
                        }
                    }
                    .scrollDisabled(!(titleFocus || descriptionFocus)) // 키보드가 내려가면 스크롤 비활성화
                    Spacer()
                }
                .onAppear {
                    if let schedule = schedule {
                        startDate = schedule.timeLine.0
                        endDate = schedule.timeLine.1
                        title = schedule.title
                        location = schedule.location
                        description = schedule.description
                        color = schedule.color
                    }
                    else {
                        startDate = plannerVM.getMergedDate(
                            for: plannerVM.selectDate,
                            with: plannerVM.today,
                            forComponents: [.year, .month, .day],
                            withComponents: [.hour, .minute]
                        )
                        endDate = startDate.addingTimeInterval(1800)
                    }
                }
                .onChange(of: startDate) { _ in
                    endDate = plannerVM.getMergedDate(
                        for: startDate,
                        with: endDate,
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
                .sheet(isPresented: $tapstartDate) {
                    DateTimePicker(
                        selectedTime: $startDate,
                        component: .hourAndMinute
                    )
                    .onChange(of: startDate) { date in
                        if date > endDate {
                            endDate = date.addingTimeInterval(1800)
                        }
                    }
                }
                .sheet(isPresented: $tapendDate) {
                    DateTimePicker(
                        selectedTime: $endDate,
                        component: .hourAndMinute
                    )
                    .onChange(of: endDate) { date in
                        if date < startDate {
                            endDate = startDate
                        }
                    }
                }
                .sheet(isPresented: $tapStartDate) {
                    DateTimePicker(
                        selectedTime: $startDate,
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
        .onChange(of: schedule) { value in
            if schedule == nil {
                currentDetent = currentDetent.union([.fraction(0.07)])
                selectedDetent = .fraction(0.07)
                DispatchQueue.main.async {
                    currentDetent = currentDetent.subtracting([.large, .fraction(0.4)])
                }
            }
            else {
                currentDetent = currentDetent.union([.large, .fraction(0.4)])
                selectedDetent = .fraction(0.4)
                DispatchQueue.main.async {
                    currentDetent = currentDetent.subtracting([.fraction(0.07)])
                }
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    uiVM.bottomPadding = proxy.size.height
                }
                Color.clear.onChange(of: proxy.size.height) { height in
                    if selectedDetent != .large {
                        uiVM.bottomPadding = height
                    }
                }
            }
                .ignoresSafeArea(.all, edges: .bottom)
        )
        
    }
}

#Preview {
    ScheduleView(
        schedule: .constant(nil)
    )
    .environmentObject(PlannerViewModel())
    .environmentObject(FirebaseViewModel())
    .environmentObject(UIViewModel())
}
