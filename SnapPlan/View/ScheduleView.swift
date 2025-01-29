//
//  ScheduleView.swift
//  SnapPlan
//
//  Created by opfic on 1/17/25.
//

import SwiftUI

struct ScheduleView: View {
    @Binding var schedule: TimeData?
    @Binding var tapButton: Bool
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

    var body: some View {
        VStack {
            if !tapButton {
                HStack {
                    Text("선택된 이벤트 없음")
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                        .padding(.leading)
                    Spacer()
                    Button(action: {
                        tapButton = true
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
                        tapButton = false
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.white, Color.gray)
                            .font(.system(size: 30))
                            .rotationEffect(.degrees(45))
                    }
                }
                TextField("제목", text: $title)
                
                    
            }
            Spacer()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .padding()
    }
}

#Preview {
    ScheduleView(
        schedule: .constant(nil),
        tapButton: .constant(false)
    )
}
