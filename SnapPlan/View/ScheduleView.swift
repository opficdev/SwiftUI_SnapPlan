//
//  ScheduleView.swift
//  SnapPlan
//
//  Created by opfic on 1/17/25.
//

import SwiftUI

struct ScheduleView: View {
    let colorArr = [
        Color.macBlue, Color.macPurple, Color.macPink, Color.macRed,
        Color.macOrange, Color.macYellow, Color.macGreen
    ]
    @Binding var schedule: TimeData?
    @EnvironmentObject private var plannerVM: PlannerViewModel
//    @State private var addSchedule = false  //  스케줄 버튼 탭 여부
    @State private var addSchedule = true  //  스케줄 버튼 탭 여부
    @State private var currentDetent:Set<PresentationDetent> = [.fraction(0.07)]
    @State private var selectedDetent: PresentationDetent = .fraction(0.07)
    @State private var title = ""
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var tapStartTime = false
    @State private var tapEndTime = false
    @FocusState private var keyboardFocus: Bool
    
    init(schedule: Binding<TimeData?>) {
        self._schedule = schedule
        let now = Date()
        self._startTime = State(initialValue: now)
        self._endTime = State(initialValue: now.addingTimeInterval(1800))
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
                        keyboardFocus = true
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
                HStack {
                    Spacer()
                    if title.isEmpty {
                        Button(action: {
                            addSchedule = false
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
                    TextField("제목", text: $title)
                        .font(.headline)
                        .focused($keyboardFocus)
                        .textSelection(.enabled)
                    Divider()
                    HStack(spacing: 10) {
                        Image(systemName: "clock")
                            .foregroundStyle(Color.gray)
                        VStack {
                            HStack {
                                Text(plannerVM.getHoursAndMiniute(
                                    for: startTime, is12hoursFmt: true)
                                )
                                .foregroundStyle(tapStartTime ? Color.blue : Color.primary)
                                .onTapGesture {
                                    tapStartTime.toggle()
                                    tapEndTime = false
                                }
                                Image(systemName: "arrow.right")
                                    .foregroundStyle(Color.gray)
                                    .padding(.horizontal)
                                Text(plannerVM.getHoursAndMiniute(
                                    for: endTime, is12hoursFmt: true)
                                )
                                .foregroundStyle(tapEndTime ? Color.blue : Color.primary)
                                .onTapGesture {
                                    tapEndTime.toggle()
                                    tapStartTime = false
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .scrollDisabled(!keyboardFocus) // 키보드가 내려가면 스크롤 비활성화
            }
            Spacer()
        }
        .onTapGesture {
            if keyboardFocus {
                keyboardFocus = false
                currentDetent = [.large, .fraction(0.4)]
            }
        }
        .presentationDetents(currentDetent, selection: $selectedDetent)
        .padding()
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
    }
}

#Preview {
    ScheduleView(
        schedule: .constant(nil)
    )
    .environmentObject(PlannerViewModel())
}
