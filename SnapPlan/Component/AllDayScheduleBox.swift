//
//  AllDayScheduleBox.swift
//  SnapPlan
//
//  Created by opfic on 2/24/25.
//

import SwiftUI

struct AllDayScheduleBox: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var schedule: ScheduleData?
    @State private var boxHeight: CGFloat
    
    init(height: CGFloat, schedule: Binding<ScheduleData?>) {
        self._boxHeight = State(initialValue: height)
        self._schedule = schedule
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.colorArray[schedule!.color], lineWidth: 2)
                .brightness(colorScheme == .light ? 0.4 : 0)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.colorArray[schedule!.color])
                        .brightness(colorScheme == .light ? 0.4 : 0)
                        .opacity(0.8)
                )
            Text(schedule!.title)
                .font(.caption)
                .foregroundStyle(Color.gray)
        }
            .frame(width: UIScreen.main.bounds.width * 6 / 7 - 4 ,height: max(boxHeight, 4))
            .offset(y: 2)
    }
}

#Preview {
    AllDayScheduleBox(
        height: 20,
        schedule: .constant(ScheduleData(startDate: Date(), endDate: Date()))
    )
}
