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
    @State private var addSchedule = false  //  스케줄 버튼 탭 여부
    @State private var currentDetent:Set<PresentationDetent> = [.fraction(0.07)]
    @State private var selectedDetent: PresentationDetent = .fraction(0.07)
    @State private var title = ""
    @FocusState private var keyboardFocus: Bool

    var body: some View {
        VStack {
            if !addSchedule {
                HStack {
                    Text("선택된 이벤트 없음")
                        .font(.footnote)
                        .foregroundStyle(Color.gray)
                        .padding(.leading)
                    Spacer()
                    Button(action: {
                        addSchedule = true
                        keyboardFocus = true
                        currentDetent = currentDetent.union([.large])
                        selectedDetent = .large
                        DispatchQueue.main.async {
                            currentDetent = currentDetent.subtracting([.fraction(0.07)])
                        }
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
                            addSchedule = false
                            currentDetent = currentDetent.union([.fraction(0.07)])
                            selectedDetent = .fraction(0.07)
                            DispatchQueue.main.async {
                                currentDetent = currentDetent.subtracting([.large])
                            }
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
                            addSchedule = false
                            currentDetent = currentDetent.union([.fraction(0.07)])
                            selectedDetent = .fraction(0.07)
                            DispatchQueue.main.async {
                                currentDetent = currentDetent.subtracting([.large])
                            }
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
            Spacer()
        }
        .onTapGesture {
            if keyboardFocus {
                keyboardFocus = false
                currentDetent = [.large, .fraction(0.4)]
            }
        }
        .presentationDetents(currentDetent, selection: $selectedDetent)
        .padding()
    }
}

#Preview {
    ScheduleView(
        schedule: .constant(nil)
    )
}
