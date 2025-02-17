//
//  RepeatSetting.swift
//  SnapPlan
//
//  Created by opfic on 2/3/25.
//

import SwiftUI


struct ScheduleCycleView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var plannerVM: PlannerViewModel
    let screenWidth = UIScreen.main.bounds.width
    @State private var sheetHeight = CGFloat.zero
    @Binding var schedule: ScheduleData?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if schedule?.cycleOption != Optional.none {
                Text("반복 안함")
                    .onTapGesture {
                        schedule?.cycleOption = .none
                        dismiss()
                    }
                    .padding(.leading, screenWidth / 5)
                    .padding(.top, 20)
            }
            Divider()
            Group {
                Text("매일")
                    .onTapGesture {
                        schedule?.cycleOption = .everyDay
                        dismiss()
                    }
                    .foregroundStyle(schedule?.cycleOption == .everyDay ? Color.blue : Color.primary)
                HStack {
                    Text("매 평일")
                        .onTapGesture {
                            schedule?.cycleOption = .everyWeekDays
                            dismiss()
                        }
                        .foregroundStyle(schedule?.cycleOption == .everyWeekDays ? Color.blue : Color.primary)
                    Text("월~금")
                        .foregroundStyle(Color.gray)
                }
                HStack {
                    Text("매주")
                        .onTapGesture {
                            schedule?.cycleOption = .everyWeek
                            dismiss()
                        }
                        .foregroundStyle(schedule?.cycleOption == .everyWeek ? Color.blue : Color.primary)
                    Text(plannerVM.getDateString(for: plannerVM.selectDate, components: [.weekday]))
                        .foregroundStyle(Color.gray)
                }
                HStack {
                    Text("매 2주")
                        .onTapGesture {
                            schedule?.cycleOption = .every2Week
                            dismiss()
                        }
                        .foregroundStyle(schedule?.cycleOption == .every2Week ? Color.blue : Color.primary)
                    Text(plannerVM.getDateString(for: plannerVM.selectDate, components: [.weekday]))
                        .foregroundStyle(Color.gray)
                }
                HStack {
                    Text("매달")
                        .onTapGesture {
                            schedule?.cycleOption = .everyMonth
                            dismiss()
                        }
                        .foregroundStyle(schedule?.cycleOption == .everyMonth ? Color.blue : Color.primary)
                    Text(plannerVM.getDateString(for: plannerVM.selectDate, components: [.day]))
                        .foregroundStyle(Color.gray)
                }
                HStack {
                    Text("매년")
                        .onTapGesture {
                            schedule?.cycleOption = .everyYear
                            dismiss()
                        }
                        .foregroundStyle(schedule?.cycleOption == .everyYear ? Color.blue : Color.primary)
                    Text(plannerVM.getDateString(for: plannerVM.selectDate, components: [.month, .day]))
                        .foregroundStyle(Color.gray)
                }
            }
            .padding(.leading, screenWidth / 5)
            Divider()
            Text("사용자 지정")
                .onTapGesture {
                    schedule?.cycleOption = .custom
                }
                .foregroundStyle(schedule?.cycleOption == .custom ? Color.blue : Color.primary)
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
}

#Preview {
    ScheduleCycleView(schedule: .constant(nil))
        .environmentObject(PlannerViewModel())
}
