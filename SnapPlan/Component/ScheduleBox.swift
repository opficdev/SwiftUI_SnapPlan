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
    @Binding var schedule: ScheduleData?
    @Binding var isChanging: Bool
    @State private var height: CGFloat
    @State private var isVisible = true
    @State private var lastDate = Date()
    @State private var gap: CGFloat
    @State private var timeZoneHeight: CGFloat
    @State private var colorIdx: Int
    
    init(gap: CGFloat, timeZoneHeight: CGFloat, height: CGFloat,  isChanging: Binding<Bool>, schedule: Binding<ScheduleData?> = .constant(nil)) {
        self._isChanging = isChanging
        self._schedule = schedule
        self._height = State(initialValue: height)
        if let schedule = schedule.wrappedValue {
            lastDate = schedule.timeLine.1
        }
        self._gap = State(initialValue: gap)
        self._timeZoneHeight = State(initialValue: timeZoneHeight)
        if let schedule = schedule.wrappedValue {
            colorIdx = schedule.color
        }
        else {
            colorIdx = 0
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            RoundedRectangle(cornerRadius: 4)
                .stroke(colorArr[colorIdx], lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorArr[colorIdx].opacity(!isVisible ? 0.5 : 0.8))
                )
                .frame(width: proxy.size.width - 4, height: height - 2) //  4: stroke 두께 * 2
                .onAppear {
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                        if isChanging {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                isVisible.toggle()
                            }
                        }
                    }
                }
                .onChange(of: schedule) { schedule in
                    if let schedule = schedule {
                        colorIdx = schedule.color
                    }
                }
                .onChange(of: isChanging) { value in
                    if !value {
                        isVisible = true
                    }
                }
                .overlay {
                    if let title = schedule?.title {
                        Text(title)
                            .foregroundStyle(Color.gray)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(x: 4, y: 8 - height / 2)
                    }
                    if isChanging {
                        Circle()
                            .stroke(colorArr[colorIdx], lineWidth: 2)
                            .frame(width: 12, height: 12)
                            .background(
                                Circle().fill(Color.timeLine)
                                    .frame(width: 12, height: 12)
                            )
                            .offset(x: -proxy.size.width * 0.4, y: 2 - height / 2)
                        
                        Circle()
                            .stroke(colorArr[colorIdx], lineWidth: 2)
                            .frame(width: 12, height: 12)
                            .background(
                                Circle().fill(Color.timeLine)
                                    .frame(width: 12, height: 12)
                            )
                            .padding()
                            .offset(x: proxy.size.width * 0.4, y: -2 + height / 2)
                            .onAppear {
                                if let schedule = schedule {
                                    lastDate = schedule.timeLine.1
                                }
                            }
                            .highPriorityGesture(   //  뷰의 제스처를 다른 뷰의 제스처(스크롤 포함)보다 우선적으로 처리
                                DragGesture()
                                    .onChanged { offset in
                                        withAnimation(.easeInOut(duration: 0.05)) { //  과도한 AnimatablePair 변경 방지
                                            height = max(CGFloat(Int(offset.translation.height)) * 2, 15)   //  소수점이 남아있으면 너무 과도한 변동값들이 나타남
//                                            schedule?.timeLine.1 = getDateFromOffset(date: lastDate, offset: height)
                                        }
                                    }
                                    .onEnded{ _ in
                                        if let schedule = schedule {
                                            lastDate = schedule.timeLine.1
                                        }
                                    }
                            )
                    }
                }
                //  x: Circle() stroke가 2라서
                //  y: 5: Circle()의 offset, 4: Circle()의 크기 - 테두리 두께
                .offset(x: 2, y: 5 + 4)
        }
    }
    
    func getDateFromOffset(date: Date, offset: CGFloat) -> Date {
        let calendar = Calendar.current
        let minutes = offset * 1440 / ((timeZoneHeight + gap) * 24)
        return calendar.date(byAdding: .minute, value: Int(minutes), to: date)!
    }
}

#Preview {
    ScheduleBox(
        gap: 10,
        timeZoneHeight: 20,
        height: 100,
        isChanging: .constant(true),
        schedule: .constant(nil)
    )
}
