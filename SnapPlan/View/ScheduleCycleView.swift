//
//  CycleOptionView.swift
//  SnapPlan
//
//  Created by opfic on 2/3/25.
//

import SwiftUI


struct CycleOptionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var plannerVM: PlannerViewModel
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    let screenWidth = UIScreen.main.bounds.width
    @State private var sheetHeight = CGFloat.zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if scheduleVM.cycleOption != .none {
                Text("반복 안함")
                    .onTapGesture {
                        scheduleVM.cycleOption = .none
                        dismiss()
                    }
                    .padding(.leading, screenWidth / 5)
                    .padding(.top, 20)
            }
            Divider()
            Group {
                Text("매일")
                    .onTapGesture {
                        scheduleVM.cycleOption = .daily
                        dismiss()
                    }
                    .foregroundStyle(scheduleVM.cycleOption == .daily ? Color.blue : Color.primary)
                HStack {
                    Text("매 평일")
                        .onTapGesture {
                            scheduleVM.cycleOption = .weekdays
                            dismiss()
                        }
                        .foregroundStyle(scheduleVM.cycleOption == .weekdays ? Color.blue : Color.primary)
                    Text("월~금")
                        .foregroundStyle(Color.gray)
                }
                HStack {
                    Text("매주")
                        .onTapGesture {
                            scheduleVM.cycleOption = .weekly
                            dismiss()
                        }
                        .foregroundStyle(scheduleVM.cycleOption == .weekly ? Color.blue : Color.primary)
                    Text(plannerVM.getDateString(for: plannerVM.selectDate, components: [.weekday]))
                        .foregroundStyle(Color.gray)
                }
                HStack {
                    Text("매 2주")
                        .onTapGesture {
                            scheduleVM.cycleOption = .biweekly
                            dismiss()
                        }
                        .foregroundStyle(scheduleVM.cycleOption == .biweekly ? Color.blue : Color.primary)
                    Text(plannerVM.getDateString(for: plannerVM.selectDate, components: [.weekday]))
                        .foregroundStyle(Color.gray)
                }
                HStack {
                    Text("매달")
                        .onTapGesture {
                            scheduleVM.cycleOption = .monthly
                            dismiss()
                        }
                        .foregroundStyle(scheduleVM.cycleOption == .monthly ? Color.blue : Color.primary)
                    Text(plannerVM.getDateString(for: plannerVM.selectDate, components: [.day]))
                        .foregroundStyle(Color.gray)
                }
                HStack {
                    Text("매년")
                        .onTapGesture {
                            scheduleVM.cycleOption = .yearly
                            dismiss()
                        }
                        .foregroundStyle(scheduleVM.cycleOption == .yearly ? Color.blue : Color.primary)
                    Text(plannerVM.getDateString(for: plannerVM.selectDate, components: [.month, .day]))
                        .foregroundStyle(Color.gray)
                }
            }
            .padding(.leading, screenWidth / 5)
            Divider()
//            Text("사용자 지정")
//                .onTapGesture {
//                    scheduleVM.cycleOption = .custom
//                }
//                .foregroundStyle(scheduleVM.cycleOption == .custom ? Color.blue : Color.primary)
//                .padding(.leading, screenWidth / 5)
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
}
