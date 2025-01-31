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
    @Binding var tapButton: Bool
    @Binding var currentDetent: Set<PresentationDetent>
    @State private var title = ""
    @State private var keyboardHeight = CGFloat.zero
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
                        currentDetent = [.large]
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
                            currentDetent = [.fraction(0.07)]
                            tapButton = false
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
                            currentDetent = [.fraction(0.07)]
                            tapButton = false
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
                        .font(.title)
                        .focused($keyboardFocus)
                        .textSelection(.enabled)
                        .onAppear {
                            keyboardFocus = true
                        }
                    Divider()
                }
                .scrollDisabled(!keyboardFocus)
            }
        }
        .onTapGesture {
            keyboardFocus = false
        }
        .interactiveDismissDisabled(keyboardFocus)
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
