//
//  ScheduleData.swift
//  SnapPlan
//
//  Created by opfic on 1/17/25.
//

import Foundation

struct ScheduleData: Identifiable {
    let id = UUID() //  UUID
    var title: String   // 일정 제목
    var timeLine: (Date, Date)  // 일정 시간 범위
    var isChanging = false  // 일정 시간 변경 중인지 확인
    var cycleOption: CycleOption    // 일정 반복 주기
    var location: String // 일정 장소
    var description: String  // 일정 설명
    var color: Int  // 일정 색상(뷰에서 사용할 Color 배열의 인덱스임)
    
    init(
        title: String,
        timeLine: (Date, Date),
        cycleOption: CycleOption = .none,
        location: String = "",
        description: String = "",
        color: Int = 0
    ) {
        self.title = title
        self.timeLine = timeLine
        self.cycleOption = cycleOption
        self.location = location
        self.description = description
        self.color = color
    }
    
    mutating func setTitle(newTitle: String) {
        self.title = newTitle
    }
    
    mutating func setTimeLine(newTimeLine: (Date?, Date?)) {
        if let startTime = newTimeLine.0 {
            self.timeLine.0 = startTime
        }
        if let endTime = newTimeLine.1 {
            self.timeLine.1 = endTime
        }
    }
    
    mutating func setCycleOption(newCycleOption: CycleOption) {
        self.cycleOption = newCycleOption
    }
    
    enum CycleOption: String {
        case none = "none"
        case everyDay = "everyDay"
        case everyWeekDays = "everyWeekDays"
        case everyWeek = "everyWeek"
        case every2Week = "every2Week"
        case everyMonth = "everyMonth"
        case everyYear = "everyYear"
        case custom = "custom"
    }
}
