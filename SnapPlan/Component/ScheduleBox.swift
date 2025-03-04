//
//  ScheduleBox.swift
//  SnapPlan
//
//  Created by opfic on 1/21/25.
//

import SwiftUI

struct ScheduleBox: View {
    let colorArr = [
        Color.macBlue, Color.macPurple, Color.macPink, Color.macRed,
        Color.macOrange, Color.macYellow, Color.macGreen
    ]
    @Environment(\.colorScheme) var colorScheme
    @Binding var schedule: ScheduleData?
    @State private var isChanging: Bool
    @State private var startOffset = CGFloat.zero
    @State private var boxHeight = CGFloat.zero
    @State private var lastHeight = CGFloat.zero
    @State private var isVisible = true
    @State private var gap: CGFloat
    @State private var timeZoneHeight: CGFloat
    @State private var colorIdx: Int
    @State private var didDateChangedByDrag = false //  드래그로 일정 시간 변경 시 true
    
    init(gap: CGFloat, timeZoneHeight: CGFloat, isChanging: Bool, schedule: Binding<ScheduleData?>) {
        self._isChanging = State(initialValue: isChanging)
        self._schedule = schedule
        self._gap = State(initialValue: gap)
        self._timeZoneHeight = State(initialValue: timeZoneHeight)
        if let schedule = schedule.wrappedValue {
            self.colorIdx = schedule.color
            let (startOffset, boxHeight) = getScheduleBoxOffset(
                from: schedule,
                timeZoneHeight: timeZoneHeight,
                gap: gap
            )
            self._startOffset = State(initialValue: startOffset)
            self._boxHeight = State(initialValue: boxHeight)
            self._lastHeight = State(initialValue: boxHeight)
        }
        else {
            self.colorIdx = 0
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 4)
                .stroke(colorArr[colorIdx], lineWidth: 2)
                .brightness(colorScheme == .light ? 0.4 : 0)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorArr[colorIdx])
                        .brightness(colorScheme == .light ? 0.4 : 0)
                        .opacity(!isVisible ? 0.5 : 0.8)
                )
                .frame(width: proxy.size.width - 4, height: max(boxHeight - 2, 4)) //  4: stroke 두께 * 2
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                        if isChanging {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                isVisible.toggle()
                            }
                        }
                    }
                }
                .onChange(of: schedule?.color) { color in
                    colorIdx = color ?? 0
                }
                .onChange(of: schedule?.startDate) { date in
                    if let date = date {
                        if !didDateChangedByDrag {
                            startOffset = getOffsetFromDate(for: date, timeZoneHeight: timeZoneHeight, gap: gap)
                            boxHeight = getOffsetFromDate(for: schedule!.endDate, timeZoneHeight: timeZoneHeight, gap: gap) - startOffset
                            lastHeight = boxHeight
                        }
                    }
                }
                .onChange(of: schedule?.endDate) { date in
                    if let date = date {
                        if !didDateChangedByDrag {  //  드래그 시 알아서 시간이 변경되므로 조건 추가
                            boxHeight = getOffsetFromDate(for: date, timeZoneHeight: timeZoneHeight, gap: gap) - startOffset
                            lastHeight = boxHeight
                        }
                    }
                }
                .onChange(of: isChanging) { value in
                    if !value {
                        isVisible = true
                    }
                }
                .overlay {
                    if let title = schedule?.title, boxHeight > UIFont.preferredFont(forTextStyle: .caption1).pointSize + 4 {
                        Text(title)
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(x: 4, y: 8 - boxHeight / 2)
                    }
                    if isChanging {
                        Circle()
                            .stroke(colorArr[colorIdx], lineWidth: 2)
                            .brightness(colorScheme == .light ? 0.4 : 0)
                            .frame(width: 12, height: 12)
                            .background(
                                Circle().fill(Color.timeLine)
                                    .frame(width: 12, height: 12)
                            )
                            .padding()
                            .offset(x: -proxy.size.width * 0.4, y: 2 - boxHeight / 2)
                            .highPriorityGesture(
                                DragGesture()
                                    .onChanged { offset in
                                        didDateChangedByDrag = true
                                        withAnimation(.linear(duration: 0.1)) {
                                            if let schedule = schedule {
                                                boxHeight = max(lastHeight - offset.translation.height * 2, 4)
                                                let newDate = getDateFromOffset(date: schedule.endDate, offset: -boxHeight)
                                                startOffset = getOffsetFromDate(for: newDate, timeZoneHeight: timeZoneHeight, gap: gap)
                                                DispatchQueue.main.async {
                                                    if Calendar.current.component(.minute, from: newDate) % 5 == 0 {
                                                        self.schedule!.startDate = newDate
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .onEnded { _ in
                                        lastHeight = boxHeight
                                        didDateChangedByDrag = false
                                    }
                            )
                        
                        Circle()
                            .stroke(colorArr[colorIdx], lineWidth: 2)
                            .brightness(colorScheme == .light ? 0.4 : 0)
                            .frame(width: 12, height: 12)
                            .background(
                                Circle().fill(Color.timeLine)
                                    .frame(width: 12, height: 12)
                            )
                            .padding()
                            .offset(x: proxy.size.width * 0.4, y: -2 + boxHeight / 2)
                            .highPriorityGesture(   //  뷰의 제스처를 다른 뷰의 제스처(스크롤 포함)보다 우선적으로 처리
                                DragGesture()
                                    .onChanged { offset in
                                        didDateChangedByDrag = true
                                        withAnimation(.linear(duration: 0.1)) { //  과도한 AnimatablePair 변경 방지
                                            if let schedule = schedule {
                                                boxHeight = max(lastHeight + offset.translation.height * 2, 4)
                                                let newDate = getDateFromOffset(date: schedule.startDate, offset: boxHeight)
                                                DispatchQueue.main.async {
                                                    if Calendar.current.component(.minute, from: newDate) % 5 == 0 {
                                                        self.schedule!.endDate = newDate
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .onEnded{ _ in
                                        lastHeight = boxHeight
                                        didDateChangedByDrag = false
                                    }
                            )
                    }
                }
                //  x: Circle() stroke가 2라서
                //  y: 5: Circle()의 offset, 4: Circle()의 크기 - 테두리 두께
                .offset(x: 2, y: startOffset + timeZoneHeight / 2 + 5 + 4)
        }
    }
    
    func getDateFromOffset(date: Date, offset: CGFloat) -> Date {
        let calendar = Calendar.current
        let minutes = offset * 1440 / ((timeZoneHeight + gap) * 24)
        return calendar.date(byAdding: .minute, value: Int(minutes), to: date)!
    }
    
    func getScheduleBoxOffset(from data: ScheduleData, timeZoneHeight: CGFloat, gap: CGFloat) -> (CGFloat, CGFloat) {
        let startOffset = getOffsetFromDate(for: data.startDate, timeZoneHeight: timeZoneHeight, gap: gap)
        let endOffset = getOffsetFromDate(for: data.endDate, timeZoneHeight: timeZoneHeight, gap: gap)
        
        return (startOffset, endOffset - startOffset)
    }
    
    func getOffsetFromDate(for date: Date, timeZoneHeight: CGFloat, gap: CGFloat) -> CGFloat {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return CGFloat(Calendar.current.dateComponents([.minute], from: startOfDay, to: date).minute ?? 0) * (timeZoneHeight + gap) * 24 / 1440
    }
}

#Preview {
    ScheduleBox(
        gap: 10,
        timeZoneHeight: 20,
        isChanging: true,
        schedule: .constant(nil)
    )
}
