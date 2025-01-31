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
    @State private var currentDetent:Set<PresentationDetent> = [.fraction(0.07)]
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
                    Divider()
                }
                .scrollDisabled(!keyboardFocus) // 키보드가 내려가면 스크롤 비활성화
            }
        }
        .onAppear {
            keyboardFocus = true
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notificiaton in
                if let keyboardFrame = notificiaton.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    let screenHeight = UIScreen.main.bounds.height
                    currentDetent = [.fraction((screenHeight * 0.95 - keyboardFrame.height) / screenHeight), .fraction(0.1)]
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                currentDetent = [.fraction(0.95), .fraction(0.4)] // 키보드가 내려가면 다시 99%로
           }
        }
        .onTapGesture {
            keyboardFocus = false
            currentDetent = [.fraction(0.95), .fraction(0.4)]
        }
        .interactiveDismissDisabled(true)  //
        .presentationDetents(currentDetent)
        .padding()
    }
}

#Preview {
    ScheduleView(
        schedule: .constant(nil),
        tapButton: .constant(false)
    )
}
