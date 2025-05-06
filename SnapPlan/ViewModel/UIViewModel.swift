//
//  UIViewModel.swift
//  SnapPlan
//
//  Created by opfic on 2/11/25.
//

import SwiftUI

class UIViewModel: ObservableObject {
    @Published var showScheduleView = true
    @Published var showSettingView = false
    @Published var allDayPadding = CGFloat.zero    //  종일 이벤트를 보여주는 뷰에 의해 가려지는 만큼 ScrollView 내부에 추가되는 패딩
    @Published var sheetPadding = CGFloat.zero //  sheet에 의해 가려지는 만큼 ScrollView 내부에 추가되는 패딩
    @Published var currentDetent:Set<PresentationDetent> = [.fraction(0.07)]    //  ScheduleView에 쓰이는 detents
    @Published var selectedDetent: PresentationDetent = .fraction(0.07)   //  ScheduelView에서 현재 선택된 detent
    
    private var onAppear = true    //  첫번째 시작일 경우
    
    func findSchedules(containing date: Date, in dict: [String: ScheduleData]) -> [ScheduleData] {
        return dict.values.filter { schedule in
            let startDate = Calendar.current.startOfDay(for: schedule.startDate)
            let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: schedule.endDate)!
            return startDate <= date && date <= endDate
        }
    }
    
    func setAllDayPadding(date: Date, height: CGFloat, schedules: [String:ScheduleData]) {
        DispatchQueue.main.async {
            let todaySchedules = self.findSchedules(containing: date, in: schedules)
            let count = todaySchedules.filter { $0.isAllDay }.count
            withAnimation(self.onAppear ? nil : .easeInOut) {
                if count < 2 {
                    self.allDayPadding = height * 2
                }
                else {
                    self.allDayPadding = (height + 3) * CGFloat(count) + 2
                }
            }
            self.onAppear = false
        }
    }
    
    func setAppTheme(_ style: UIUserInterfaceStyle) {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = style
                }
            }
        }
    }
}
