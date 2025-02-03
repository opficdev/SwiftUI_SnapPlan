//
//  RepeatSetting.swift
//  SnapPlan
//
//  Created by opfic on 2/3/25.
//

import SwiftUI

struct RepeatSetting: View {
    @Environment(\.dismiss) var dismiss
    let screenWidth = UIScreen.main.bounds.width
    @State private var sheetHeight = CGFloat.zero
    @State private var selectedOption: RepeatOption = .none
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if selectedOption != .none {
                Text("반복 안함")
                    .onTapGesture {
                        selectedOption = .none
                        dismiss()
                    }
            }
            Divider()
            Group {
                Text("매일")
                    .onTapGesture {
                        selectedOption = .everyDay
                        dismiss()
                    }
                    .foregroundStyle(selectedOption == .everyDay ? Color.blue : Color.primary)
                Text("매주")
                    .onTapGesture {
                        selectedOption = .everyWeek
                        dismiss()
                    }
                    .foregroundStyle(selectedOption == .everyWeek ? Color.blue : Color.primary)
                Text("2주")
                    .onTapGesture {
                        selectedOption = .every2Week
                        dismiss()
                    }
                    .foregroundStyle(selectedOption == .every2Week ? Color.blue : Color.primary)
                Text("매달")
                    .onTapGesture {
                        selectedOption = .everyMonth
                        dismiss()
                    }
                    .foregroundStyle(selectedOption == .everyMonth ? Color.blue : Color.primary)
                Text("매년")
                    .onTapGesture {
                        selectedOption = .everyYear
                        dismiss()
                    }
                    .foregroundStyle(selectedOption == .everyYear ? Color.blue : Color.primary)
            }
            .padding(.leading, screenWidth / 5)
            Divider()
            Text("사용자 지정")
                .onTapGesture {
                    selectedOption = .custom
                }
                .foregroundStyle(selectedOption == .custom ? Color.blue : Color.primary)
                .padding(.leading, screenWidth / 5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    sheetHeight = geometry.size.height
                }
            }
        )
        .presentationDragIndicator(.visible)
        .presentationDetents([.height(sheetHeight)])
    }
    
    enum RepeatOption {
        case none, everyDay, everyWeek, every2Week, everyMonth, everyYear, custom
    }
}

#Preview {
    RepeatSetting()
}
