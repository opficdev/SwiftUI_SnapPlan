//
//  UIViewModel.swift
//  SnapPlan
//
//  Created by opfic on 2/11/25.
//

import SwiftUI

class UIViewModel: ObservableObject {
    @Published var allDayPadding = CGFloat.zero    //  종일 이벤트를 보여주는 뷰에 의해 가려지는 만큼 ScrollView 내부에 추가되는 패딩
    @Published var sheetPadding = CGFloat.zero //  sheet에 의해 가려지는 만큼 ScrollView 내부에 추가되는 패딩
    private var onAppear = true    //  첫번째 시작일 경우
    
    func findSchedules(containing date: Date, in dict: [String: ScheduleData]) -> [ScheduleData] {
        return dict.values.filter { schedule in
            let startDate = Calendar.current.startOfDay(for: schedule.startDate)
            let endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: schedule.endDate)!
            return startDate <= date && date <= endDate
        }
    }

}
