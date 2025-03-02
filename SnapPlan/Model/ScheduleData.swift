//
//  ScheduleData.swift
//  SnapPlan
//
//  Created by opfic on 1/17/25.
//

import Foundation

struct ScheduleData: Identifiable {
    let id: UUID //  UUID
    var title: String   // 일정 제목
    var timeLine: (Date, Date)  // 일정 시간 범위
    var isChanging: Bool  // 일정 시간 변경 중인지 확인
    var allDay: Bool // 종일 일정 여부
    var cycleOption: CycleOption    // 일정 반복 주기
    var location: String // 일정 장소
    var address: String  // 장소에 대한 주소
    var description: String  // 일정 설명
    var color: Int  // 일정 색상(뷰에서 사용할 Color 배열의 인덱스임)
    
    init(
        id: UUID = UUID(),
        title: String = "",
        timeLine: (Date, Date), //  .0과 .1이 날짜가 다를 수 있어서 [(Date, Date), (Date, Date)...] 형태로 변경 예정
        isChanging: Bool = false,
        allDay: Bool = false,
        cycleOption: CycleOption = .none,
        location: String = "",
        address: String = "",
        description: String = "",
        color: Int = 0
    ) {
        self.id = id
        self.title = title
        self.timeLine = timeLine
        self.isChanging = isChanging
        self.allDay = allDay
        self.cycleOption = cycleOption
        self.location = location
        self.address = address
        self.description = description
        self.color = color
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
