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
    @EnvironmentObject var plannerVM: PlannerViewModel
    @EnvironmentObject var supabaseVM: SupabaseViewModel
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @EnvironmentObject var uiVM: UIViewModel
    @StateObject var searchVM = SearchLocationViewModel()
    
    @State private var startTask = false     //  스케줄 CRUD 작업 시작여부
    @State private var currentDetent:Set<PresentationDetent> = [.fraction(0.07)]
    @State private var selectedDetent: PresentationDetent = .fraction(0.07)
    @State private var tapStartTime = false //  시작 시간 탭 여부
    @State private var tapStartDate = false //  시작 날짜 탭 여부
    @State private var tapEndTime = false   //  종료 시간 탭 여부
    @State private var tapEndDate = false   //  종료 시간 탭 여부
    @State private var tapRepeat = false    //  반복 탭 여부
    @State private var tapLocation = false  //  위치 탭 여부
    @State private var tapColor = false  //  색상 탭 여부
    @State private var tapDeleteSchedule = false   //  스케줄 삭제 탭 여부
    @State private var tapVoiceMemo = false   //  음성 메모 탭 여부
    @State private var sheetMinHeight = CGFloat.zero //    sheet 최소 높이
    
    @FocusState private var titleFocus: Bool    //  제목 포커싱 여부
    @State private var descriptionFocus = false   //  설명 포커싱 여부
    //  plannerVM.selectDate와 scheduleVM.startDate의 년월일이 다른 경우
    //  startDate가 변경되지 않는 이상 selectDate를 따르게 하려고
    //  해당 변수를 추가하였음
    @State private var didChangedStartDate = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if startTask {
                    VStack {
                        HStack {
                            Spacer()
                            if scheduleVM.title.isEmpty {
                                Button(action: {
                                    titleFocus = false
                                    descriptionFocus = false
                                    scheduleVM.schedule = nil
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(Color.white, Color.gray.opacity(0.2))
                                        .font(.system(size: 30))
                                }
                            }
                            else {
                                Menu(content: {
                                    Button(action: {
                                        titleFocus = false
                                        descriptionFocus = false
                                        scheduleVM.schedule = nil
                                    }) {
                                        Label("취소", systemImage: "xmark")
                                    }
                                    Button(action: {
                                        let copy = ScheduleData(
                                            title: scheduleVM.title,
                                            startDate: scheduleVM.startDate.addingTimeInterval(3600),
                                            endDate: scheduleVM.endDate.addingTimeInterval(3600),
                                            color: scheduleVM.color,
                                            location: scheduleVM.location,
                                            description: scheduleVM.description
                                        )
                                        Task {
                                            do {
                                                try await supabaseVM.upsertSchedule(schedule: copy)
                                                supabaseVM.setSchedule(schedule: copy)
                                            } catch {
                                                print("스케줄 복사본 추가/수정 실패: \(error.localizedDescription)")
                                            }
                                        }
                                        Task {
                                            try await supabaseVM.upsertPhotos(id: copy.id, photos: scheduleVM.photos)
                                            if let voiceMemo = scheduleVM.voiceMemo {
                                                try await supabaseVM.upsertVoiceMemo(id: copy.id, memo: voiceMemo)
                                            }
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
                                
                                Button(action: {
                                    Task {
                                        let id = scheduleVM.id!
                                        let photos = scheduleVM.photos
                                        let voiceMemo = scheduleVM.voiceMemo
                                        let schedule = scheduleVM.schedule!
                                        scheduleVM.schedule = nil
                                        do {
                                            startTask = false
                                            try await supabaseVM.upsertSchedule(schedule: schedule)
                                            supabaseVM.setSchedule(schedule: schedule)
                                        }
                                        catch {
                                            print("스케줄 추가/수정 실패: \(error.localizedDescription)")
                                        }
                                        do {
                                            if photos.isEmpty {
                                                try await supabaseVM.deletePhotos(id: id)
                                            }
                                            else {
                                                try await supabaseVM.upsertPhotos(id: id, photos: photos)
                                            }
                                            if let memo = voiceMemo {
                                                try await supabaseVM.upsertVoiceMemo(id: id, memo: memo)
                                            }
                                            else {
                                                try await supabaseVM.deleteVoiceMemo(id: id)
                                            }
                                        }
                                        catch {
                                            print("사진, 음성 메모 추가/수정 실패: \(error.localizedDescription)")
                                        }
                                    }
                                    titleFocus = false
                                    descriptionFocus = false
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
                                TextField("제목", text: $scheduleVM.title)
                                    .textSelection(.enabled)
                                    .font(.title2)
                                    .focused($titleFocus)
                                    .padding(.top)
                                Divider()
                                    .padding(.vertical)
                                HStack(alignment: .top) {
                                    Image(systemName: "clock")
                                        .foregroundStyle(Color.gray)
                                        .frame(width: 25)
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(spacing: 0) {
                                            Text(plannerVM.getDateString(for: scheduleVM.startDate, components: [.hour, .minute]))
                                                .foregroundStyle(tapStartTime ? Color.blue : (scheduleVM.isAllDay ? Color.gray : Color.primary))
                                                .onTapGesture {
                                                    tapStartTime.toggle()
                                                    tapEndTime = false
                                                }
                                                .frame(width: screenWidth / 4, alignment: .leading)
                                                .disabled(scheduleVM.isAllDay)
                                            Image(systemName: "arrow.right")
                                                .foregroundStyle(Color.gray)
                                                .frame(width: screenWidth / 10, alignment: .leading)
                                            Text(plannerVM.getDateString(for: scheduleVM.endDate, components: [.hour, .minute]))
                                                .foregroundStyle(tapEndTime ? Color.blue : (scheduleVM.isAllDay ? Color.gray : Color.primary))
                                                .onTapGesture {
                                                    tapEndTime.toggle()
                                                    tapStartTime = false
                                                }
                                                .disabled(scheduleVM.isAllDay)
                                        }
                                        HStack(spacing: 0) {
                                            let startDate = scheduleVM.cycleOption != .none && !didChangedStartDate ? plannerVM.selectDate : scheduleVM.startDate
                                            Text(plannerVM.getDateString(for: startDate, components: [.month, .day]))
                                                .foregroundStyle(tapStartDate ? Color.blue : Color.primary)
                                                .onTapGesture {
                                                    tapStartDate.toggle()
                                                    tapEndDate = false
                                                }
                                                .frame(width: screenWidth / 4 + screenWidth / 10, alignment: .leading)
                                            if !plannerVM.isSameDate(date1: scheduleVM.startDate, date2: scheduleVM.endDate, components: [.year, .month, .day]) || scheduleVM.isAllDay {
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
                                    Toggle("종일", isOn: $scheduleVM.isAllDay)
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
                                        Group {
                                            Image(systemName: "microphone.fill")
                                                .frame(width: 25)
                                            Text("음성 메모")
                                                .underline(scheduleVM.voiceMemo != nil)
                                        }
                                        .onTapGesture {
                                            tapVoiceMemo = true
                                            scheduleVM.audioLevels.removeAll()
                                        }
                                        if let voiceMemo = scheduleVM.voiceMemo {
                                            LinearAudioPlayer(file: .constant(voiceMemo))
                                            Button(action: {
                                                scheduleVM.voiceMemo = nil
                                                scheduleVM.recordingTime = 0.0
                                            }) {
                                                Image(systemName: "trash")
                                                    .frame(width: 25)
                                                    .foregroundStyle(Color.gray)
                                            }
                                        }
                                    }
                                    .foregroundStyle(scheduleVM.voiceMemo == nil ? Color.gray : Color.primary)
                                    HStack {
                                        NavigationLink(destination: ImageView().environmentObject(scheduleVM)) {
                                            HStack {
                                                Image(systemName: "photo")
                                                    .frame(width: 25)
                                                Text("사진")
                                                    .underline(!scheduleVM.photos.isEmpty)
                                            }
                                            .foregroundStyle(scheduleVM.photos.isEmpty ? Color.gray : Color.primary)
                                        }
                                        Spacer()
                                    }
                                    HStack {
                                        Image(systemName: "map")
                                            .frame(width: 25)
                                            .foregroundStyle(Color.gray)
                                        NavigationLink(destination: LocationView) {
                                            VStack(alignment: .leading) {
                                                Text(scheduleVM.location.isEmpty ? "위치" : scheduleVM.location)
                                                    .foregroundStyle(scheduleVM.location.isEmpty ? Color.gray : Color.primary)
                                                    .underline(!scheduleVM.address.isEmpty)
                                                    .lineLimit(1)
                                                if !scheduleVM.address.isEmpty {
                                                    Text(scheduleVM.address)
                                                        .font(.caption)
                                                        .foregroundStyle(Color.gray)
                                                        .lineLimit(1)
                                                }
                                            }
                                        }
                                        .disabled(!scheduleVM.location.isEmpty && scheduleVM.address.isEmpty)
                                        .navigationTitle("")
                                        Spacer()
                                        if !scheduleVM.location.isEmpty {
                                            NavigationLink(destination: SearchLocationView().environmentObject(searchVM).environmentObject(scheduleVM)) {
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
                        didChangedStartDate = true
                        if date >= scheduleVM.endDate {
                            scheduleVM.endDate = Calendar.current.date(byAdding: .minute, value: 30, to: date)!
                        }
                    }
                    .onChange(of: scheduleVM.endDate) { date in
                        if date <= scheduleVM.startDate {
                            scheduleVM.startDate = Calendar.current.date(byAdding: .minute, value: -30, to: date)!
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
                        CycleOptionView()
                            .environmentObject(plannerVM)
                            .environmentObject(scheduleVM)
                    }
                    .sheet(isPresented: $tapVoiceMemo) {
                        VoiceMemoView()
                            .environmentObject(scheduleVM)
                    }
                    .confirmationDialog("스케줄을 삭제하시겠습니까?", isPresented: $tapDeleteSchedule, titleVisibility: .visible) {
                        Button(role: .destructive, action: {
                            titleFocus = false
                            descriptionFocus = false
                            Task {
                                do {
                                    startTask = false
                                    let schedule = scheduleVM.schedule!
                                    scheduleVM.schedule = nil
                                    supabaseVM.removeSchedule(schedule: schedule)
                                    try await supabaseVM.deletePhotos(id: schedule.id)
                                    try await supabaseVM.deleteVoiceMemo(id: schedule.id)
                                    try await supabaseVM.deleteSchedule(schedule: schedule)
                                }
                            }
                        }) {
                            Text("삭제")
                        }
                        Button(role: .cancel, action: {
                            scheduleVM.schedule = nil
                        }) {
                            Text("취소")
                        }
                    }
                }
                else {
                    HStack {
                        Text("선택된 이벤트 없음")
                            .font(.footnote)
                            .foregroundStyle(Color.gray)
                            .padding(.leading)
                        Spacer()
                        Button(action: {
                            titleFocus = true
                            currentDetent = currentDetent.union([.large])
                            selectedDetent = .large
                            var startDate = Calendar.current.date(
                                byAdding: .minute,
                                value: 5 - Calendar.current.component(.minute, from: Date()) % 5,
                                to: Date()
                            )!
                            startDate = Calendar.current.date(byAdding: .second, value: -Calendar.current.component(.second, from: startDate), to: startDate)!
                            let endDate = startDate.addingTimeInterval(1800)
                            scheduleVM.schedule = ScheduleData(startDate: startDate, endDate: endDate)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.white, Color.gray.opacity(0.2))
                                .font(.system(size: 30))
                        }
                    }
                }
            }
            .padding()
            .presentationDetents(currentDetent, selection: $selectedDetent)
            .onChange(of: scheduleVM.schedule) { schedule in
                startTask = schedule != nil
                //  MARK: defer 내에서 scheduleVM.schedule이 nil이 될 때 startTask가 false가 되지만
                //  MARK: 이미 starTask는 false임
            }
            .onChange(of: startTask) { value in
                if value {
                    currentDetent = currentDetent.union([.large, .fraction(0.4)])
                    if selectedDetent == .fraction(0.07) {
                        selectedDetent = .fraction(0.4)
                    }
                    DispatchQueue.main.async {
                        currentDetent = currentDetent.subtracting([.fraction(0.07)])
                    }
                }
                else {
                    currentDetent = currentDetent.union([.fraction(0.07)])
                    selectedDetent = .fraction(0.07)
                    didChangedStartDate = false
                    DispatchQueue.main.async {
                        currentDetent = currentDetent.subtracting([.large, .fraction(0.4)])
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
        VStack {
            if scheduleVM.location.isEmpty {
                SearchLocationView()
                    .environmentObject(searchVM)
                    .environmentObject(scheduleVM)
            }
            else {
                MapView()
                    .environmentObject(scheduleVM)
            }
        }
        .onAppear {
            currentDetent = currentDetent.union([.large])
            selectedDetent = .large
            DispatchQueue.main.async {
                currentDetent = currentDetent.subtracting([.fraction(0.4)])
            }
        }
        .onDisappear {
            currentDetent = currentDetent.union([.fraction(0.4)])
        }
    }
}
