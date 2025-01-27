//
//  ScheduleView.swift
//  SnapPlan
//
//  Created by opfic on 1/17/25.
//

import SwiftUI

struct ScheduleView: View {
    @Binding var schedule: TimeData?
    let colorArr = [
        Color.macBlue,
        Color.macPurple,
        Color.macPink,
        Color.macRed,
        Color.macOrange,
        Color.macYellow,
        Color.macGreen
    ]
    @State private var title = ""
    @State private var addSchedule = false

    var body: some View {
        VStack {
            if schedule == nil {
                HStack {
                    Text("선택된 이벤트 없음")
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                        .padding(.leading)
                    Spacer()
                    Button(action: {
                        addSchedule = false
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.white, Color.gray)
                            .font(.system(size: 30))
                    }
                }
            }
            else {
                HStack {
                    Spacer()
                    Button(action: {
                        addSchedule = false
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.white, Color.gray)
                            .font(.system(size: 24))
                            .rotationEffect(.degrees(30))
                    }
                }
                TextField("제목", text: $title)
                
                    
            }
        }
        .padding()
    }
}

#Preview {
    ScheduleView(
        schedule: .constant(nil)
    )
}
