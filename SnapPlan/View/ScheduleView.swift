//
//  ScheduleView.swift
//  SnapPlan
//
//  Created by opfic on 1/17/25.
//
//  MARK: 메인 뷰에서 sheet에 올라오는 뷰

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var plannerVM: PlannerViewModel
    @EnvironmentObject var firebaseVM: FirebaseViewModel
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @EnvironmentObject var uiVM: UIViewModel
    @EnvironmentObject var networkVM: NetworkViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject var searchVM = SearchLocationViewModel()
    @StateObject var permissionVM = PermissionViewModel()
    
    @State private var startTask = false     //  스케줄 CRUD 작업 시작여부
    @State private var tapStartTime = false //  시작 시간 탭 여부
    @State private var tapStartDate = false //  시작 날짜 탭 여부
    @State private var tapEndTime = false   //  종료 시간 탭 여부
    @State private var tapEndDate = false   //  종료 시간 탭 여부
    @State private var tapRepeat = false    //  반복 탭 여부
    @State private var tapLocation = false  //  위치 탭 여부
    @State private var tapColor = false  //  색상 탭 여부
    @State private var tapDeleteSchedule = false   //  스케줄 삭제 탭 여부
    @State private var tapVoiceMemo = false   //  음성 메모 탭 여부
    
    @FocusState private var titleFocus: Bool    //  제목 포커싱 여부
    @State private var descriptionFocus = false   //  설명 포커싱 여부
    //  plannerVM.selectDate와 scheduleVM.startDate의 년월일이 다른 경우
    //  startDate가 변경되지 않는 이상 selectDate를 따르게 하려고
    //  해당 변수를 추가하였음
    @State private var didChangedStartDate = false
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationStack {
            VStack {
                if startTask {
                    VStack {
                        HStack {
                            Spacer()
                            if scheduleVM.title.isEmpty {
                                Button(action: {
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
                                        scheduleVM.schedule = nil
                                    }) {
                                        Label("취소", systemImage: "xmark")
                                    }
                                    if networkVM.isConnected {
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
                                                    try await firebaseVM.upsertSchedule(schedule: copy)
                                                    firebaseVM.setSchedule(schedule: copy)
                                                } catch {
                                                    print("스케줄 복사본 추가/수정 실패: \(error.localizedDescription)")
                                                }
                                            }
                                            Task {
                                                try await firebaseVM.upsertPhotos(id: copy.id, photos: scheduleVM.photos)
                                                if let voiceMemo = scheduleVM.voiceMemo {
                                                    try await firebaseVM.upsertVoiceMemo(id: copy.id, voiceMemo: voiceMemo)
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
                                    }
                                }) {
                                    Image(systemName: "ellipsis")
                                        .font(.system(size: 20))
                                        .foregroundStyle(Color.gray)
                                        .padding()
                                }
                                
                                Button(action: {
                                    let id = scheduleVM.id!
                                    let photos = scheduleVM.photos
                                    let voiceMemo = scheduleVM.voiceMemo
                                    let schedule = scheduleVM.schedule!
                                    scheduleVM.schedule = nil
                                    if networkVM.isConnected {
                                        firebaseVM.setSchedule(schedule: schedule)
                                        Task {
                                            do {
                                                try await firebaseVM.deleteVoiceMemo(id: id)
                                                try await firebaseVM.deletePhotos(id: id)
                                                try await firebaseVM.upsertSchedule(schedule: schedule)
                                            }
                                            catch {
                                                print("스케줄 추가/수정 실패: \(error.localizedDescription)")
                                            }
                                            do {
                                                if scheduleVM.photosState != .loading {
                                                    if photos.isEmpty {
                                                        try await firebaseVM.deletePhotos(id: id)
                                                    }
                                                    else {
                                                        try await firebaseVM.upsertPhotos(id: id, photos: photos)
                                                    }
                                                }
                                                if scheduleVM.memoState != .loading {
                                                    if let memo = voiceMemo {
                                                        try await firebaseVM.upsertVoiceMemo(id: id, voiceMemo: memo)
                                                    }
                                                    else {
                                                        try await firebaseVM.deleteVoiceMemo(id: id)
                                                    }
                                                }
                                            }
                                            catch {
                                                print("사진, 음성 메모 추가/수정 실패: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                }) {
                                    if networkVM.isConnected {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 40, height: 30)
                                            Text("완료")
                                                .foregroundStyle(Color.white)
                                        }
                                    }
                                    else {
                                        Image(systemName: "xmark.circle.fill")
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(Color.white, Color.gray.opacity(0.2))
                                            .font(.system(size: 30))
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
                                            Image(systemName: "mic.fill")
                                                .frame(width: 25)
                                            Text("음성 메모")
                                                .underline(scheduleVM.voiceMemo != nil)
                                        }
                                        .onTapGesture {
                                            if scheduleVM.memoState != .loading && permissionVM.checkMicPermission() {
                                                tapVoiceMemo = true
                                                scheduleVM.audioLevels.removeAll()
                                            }
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
                                        else if scheduleVM.memoState == .loading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                        }
                                        else if scheduleVM.memoState == .error {
                                            Image(systemName: "arrow.counterclockwise")
                                                .onTapGesture {
                                                    Task {
                                                        do {
                                                            if let id = scheduleVM.id {
                                                                firebaseVM.schedules[id.uuidString]?.memoState = .loading
                                                                await MainActor.run {
                                                                    scheduleVM.memoState = .loading
                                                                }
                                                                scheduleVM.voiceMemo = try await firebaseVM.fetchVoiceMemo(schedule: id)
                                                                firebaseVM.schedules[id.uuidString]?.memoState = .success
                                                                await MainActor.run {
                                                                    scheduleVM.memoState = .success
                                                                }
                                                            }
                                                        } catch {
                                                            print("음성 메모 불러오기 실패: \(error.localizedDescription)")
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                    .foregroundStyle(scheduleVM.voiceMemo == nil ? Color.gray : Color.primary)
                                    HStack {
                                        NavigationLink(destination: PhotoView().environmentObject(scheduleVM)) {
                                            HStack {
                                                Image(systemName: "photo")
                                                    .frame(width: 25)
                                                Text("사진")
                                                    .underline(!scheduleVM.photos.isEmpty)
                                                if scheduleVM.photosState == .loading {
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle())
                                                }
                                                else if scheduleVM.photosState == .error {
                                                    Image(systemName: "arrow.counterclockwise")
                                                        .onTapGesture {
                                                            Task {
                                                                do {
                                                                    if let id = scheduleVM.id {
                                                                        firebaseVM.schedules[id.uuidString]?.photosState = .loading
                                                                        await MainActor.run {
                                                                            scheduleVM.photosState = .loading
                                                                        }
                                                                        scheduleVM.photos = try await firebaseVM.fetchPhotos(schedule: id)
                                                                        firebaseVM.schedules[id.uuidString]?.photosState = .success
                                                                        await MainActor.run {
                                                                            scheduleVM.photosState = .success
                                                                        }
                                                                    }
                                                                } catch {
                                                                    print("사진 불러오기 실패: \(error.localizedDescription)")
                                                                }
                                                            }
                                                        }
                                                }
                                            }
                                            .foregroundStyle(scheduleVM.photos.isEmpty ? Color.gray : Color.primary)
                                        }
                                        .disabled(scheduleVM.photosState == StorageState.loading)
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
                        titleFocus = false
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
                            let schedule = scheduleVM.schedule!
                            scheduleVM.schedule = nil
                            Task {
                                do {
                                    firebaseVM.removeSchedule(schedule: schedule)
                                    try await firebaseVM.deletePhotos(id: schedule.id)
                                    try await firebaseVM.deleteVoiceMemo(id: schedule.id)
                                    try await firebaseVM.deleteSchedule(schedule: schedule)
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
                    .confirmationDialog(
                        permissionVM.permissionTitle,
                        isPresented: $permissionVM.showPermissionAlert,
                        titleVisibility: .visible
                    ) {
                        Button("설정으로 이동") {
                            permissionVM.openSettings()
                        }
                        Button("취소", role: .cancel) {}
                    } message: {
                        Text(permissionVM.permissionMsg)
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
                            uiVM.selectedDetent = .large
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
                                .foregroundStyle(
                                    Color.white.opacity(networkVM.isConnected || colorScheme == .light ? 1 : 0.5),
                                    Color.gray.opacity(networkVM.isConnected ? 0.2 : 0.1)
                                )
                                .font(.system(size: 30))
                        }
                        .disabled(!networkVM.isConnected)
                    }
                }
            }
            .onChange(of: scheduleVM.schedule) { schedule in
                startTask = schedule != nil
            }
            .onChange(of: startTask) { value in
                if value {
                    uiVM.currentDetent = uiVM.currentDetent.union([.large, .fraction(0.4)])
                    if uiVM.selectedDetent == .fraction(0.07) {
                        uiVM.selectedDetent = .fraction(0.4)
                    }
                    DispatchQueue.main.async {
                        uiVM.currentDetent = uiVM.currentDetent.subtracting([.fraction(0.07)])
                    }
                }
                else {
                    titleFocus = false
                    descriptionFocus = false
                    uiVM.currentDetent = uiVM.currentDetent.union([.fraction(0.07)])
                    uiVM.selectedDetent = .fraction(0.07)
                    didChangedStartDate = false
                    DispatchQueue.main.async {
                        uiVM.currentDetent = uiVM.currentDetent.subtracting([.large, .fraction(0.4)])
                    }
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            DispatchQueue.main.async {
                                uiVM.sheetPadding = proxy.size.height + UIApplication.safeAreaInsets.bottom + 12
                            }
                        }
                        .onChange(of: proxy.size.height) { height in
                            if uiVM.selectedDetent != .large {
                                DispatchQueue.main.async {
                                    uiVM.sheetPadding = height + UIApplication.safeAreaInsets.bottom + 12
                                }
                            }
                    }
                }
            )
            .padding(.horizontal)
            .padding(.top, scheduleVM.schedule == nil ? 0 : 12)
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
            uiVM.currentDetent = uiVM.currentDetent.union([.large])
            uiVM.selectedDetent = .large
            DispatchQueue.main.async {
                uiVM.currentDetent = uiVM.currentDetent.subtracting([.fraction(0.4)])
            }
        }
        .onDisappear {
            uiVM.currentDetent = uiVM.currentDetent.union([.fraction(0.4)])
        }
    }
}
