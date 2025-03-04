//
//  AllDayScheduleBox.swift
//  SnapPlan
//
//  Created by opfic on 2/24/25.
//

import SwiftUI

struct AllDayScheduleBox: View {
    let colorArr = [
        Color.macBlue, Color.macPurple, Color.macPink, Color.macRed,
        Color.macOrange, Color.macYellow, Color.macGreen
    ]
    @Environment(\.colorScheme) var colorScheme
    @Binding var schedule: ScheduleData
    @Binding var boxHeight: CGFloat
    @State private var colorIdx: Int
    
    init(height: Binding<CGFloat>, schedule: Binding<ScheduleData>) {
        self._boxHeight = height
        self._schedule = schedule
        self._colorIdx = State(initialValue: schedule.wrappedValue.color)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .stroke(colorArr[colorIdx], lineWidth: 2)
                .brightness(colorScheme == .light ? 0.4 : 0)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(colorArr[colorIdx])
                        .brightness(colorScheme == .light ? 0.4 : 0)
                        .opacity(0.8)
                )
            Text(schedule.title)
                .font(.caption)
                .foregroundStyle(Color.gray)
        }
            .frame(width: UIScreen.main.bounds.width * 6 / 7 - 4 ,height: max(boxHeight, 4))
            .offset(y: 2)
    }
}

#Preview {
    AllDayScheduleBox(
        height: .constant(20),
        schedule: .constant(ScheduleData(startDate: Date(), endDate: Date()))
    )
}
