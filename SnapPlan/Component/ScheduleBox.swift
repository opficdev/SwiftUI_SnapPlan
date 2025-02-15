//
//  ScheduleBox.swift
//  SnapPlan
//
//  Created by opfic on 1/21/25.
//

import SwiftUI

struct ScheduleBox: View {
    @Binding var schedule: ScheduleData?
    @Binding var isChanging: Bool
    @Binding var height: CGFloat
    @State private var isVisible = true
    @State private var lastDate = Date()
    @State private var gap: CGFloat
    @State private var timeZoneHeight: CGFloat
    
    init(gap: CGFloat, timeZoneHeight: CGFloat, height: Binding<CGFloat>,  isChanging: Binding<Bool>, schedule: Binding<ScheduleData?> = .constant(nil)) {
        self._isChanging = isChanging
        self._schedule = schedule
        self._height = height
        if let schedule = schedule.wrappedValue {
            lastDate = schedule.timeLine.1
        }
        self._gap = State(initialValue: gap)
        self._timeZoneHeight = State(initialValue: timeZoneHeight)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.macBlue, lineWidth: 2)
                    .frame(width: proxy.size.width - 4, height: height - 4)
                    .background(
                        GeometryReader { proxy in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.macBlue.opacity(!isVisible ? 0.5 : 0.8))
                        }
                    )
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                            if isChanging {
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    isVisible.toggle()
                                }
                            }
                        }
                    }
                    .onChange(of: isChanging) { value in
                        if !value {
                            isVisible = true
                        }
                    }
                
                
                if isChanging {
                    VStack {
                        VStack {
                            Circle()
                                .stroke(Color.macBlue, lineWidth: 2)
                                .frame(width: 12, height: 12)
                                .background(
                                    Circle().fill(Color.timeLine)
                                        .frame(width: 12, height: 12)
                                )
                                .offset(x: proxy.size.width * 0.1, y: 5)
                        }
                        .frame(width: proxy.size.width, alignment: .leading)
                        Spacer()
                        VStack {
                            Circle()
                                .stroke(Color.macBlue, lineWidth: 2)
                                .frame(width: 12, height: 12)
                                .background(
                                    Circle().fill(Color.timeLine)
                                        .frame(width: 12, height: 12)
                                )
                                .offset(x: -proxy.size.width * 0.1, y: -5)
                        }
                        .frame(width: proxy.size.width, alignment: .trailing)
                        .onAppear {
                            if let schedule = schedule {
                                lastDate = schedule.timeLine.1
                            }
                        }
                        .highPriorityGesture(   //  뷰의 제스처를 다른 뷰의 제스처(스크롤 포함)보다 우선적으로 처리
                            DragGesture()
                                .onChanged { offset in
                                    withAnimation(.easeInOut(duration: 0.05)) {
                                        schedule?.timeLine.1 = getDateFromOffset(date: lastDate, offset: offset.translation.height)
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
            }
            .offset(x: isChanging ? 0 : 2, y: 5 + 4)
            //  x에 offset이 추가되야하는지는 이유를 모르겠음
            //  5: Circle()의 offset, 4: Circle()의 크기 - 테두리 두께
            .frame(height: height)
            .onChange(of: height) { value in
                print(value)
            }
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
        height: .constant(40),
        isChanging: .constant(true),
        schedule: .constant(nil)
    )
}
