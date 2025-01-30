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
    @Binding var currentDetent: Set<PresentationDetent>
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
    @FocusState private var keyboardFocus: Bool

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
                        currentDetent = [.fraction(0.4)]  //  이거 없으면 키보드에 의해 sheet가 밀림
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
                    if title.isEmpty {
                        Button(action: {
                            currentDetent = [.fraction(0.07)]
                            tapButton = false
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.white, Color.gray)
                                .font(.system(size: 30))
                                .rotationEffect(.degrees(45))
                        }
                    }
                    else {
                        Button(action: {
                            currentDetent = [.fraction(0.07)]
                            tapButton = false
                        }) {
                            Text("완료")
                                .foregroundStyle(Color.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.macBlue)
                                )
                        }
                    }
                }
                TextField("제목", text: $title)
                    .font(.title)
                    .focused($keyboardFocus)
                    .textSelection(.enabled)
                    .onAppear {
                        keyboardFocus = true
                    }
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ScheduleView(
        schedule: .constant(nil),
        tapButton: .constant(false),
        currentDetent: .constant(Set([.fraction(0.07)]))
    )
}
