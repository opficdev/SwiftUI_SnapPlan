//
//  CodableScheduleData.swift
//  SnapPlan
//
//  Created by opfic on 3/28/25.
//

import Foundation

struct CodableScheduleData: Identifiable, Codable {
    let id: UUID //  UUID
    var title: String   // 일정 제목
    var startDate: Date // 일정 시작 날짜
    var endDate: Date   // 일정 종료 날짜
    var isAllDay: Bool // 종일 일정 여부
    var cycleOption: CycleOption    // 일정 반복 주기
    var color: Int  // 일정 색상(뷰에서 사용할 Color 배열의 인덱스임)
    var location: String
    var address: String  // 장소에 대한 주소
    var description: String  // 일정 설명
    
    init(
        id: UUID = UUID(),
        title: String = "",
        startDate: Date,
        endDate: Date,
        isAllDay: Bool = false,
        cycleOption: CycleOption = .none,
        color: Int = 0,
        location: String = "",
        address: String = "",
        description: String = ""
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.cycleOption = cycleOption
        self.color = color
        self.location = location
        self.address = address
        self.description = description
    }
    
    init(schedule: ScheduleData) {
        self.id = schedule.id
        self.title = schedule.title
        self.startDate = schedule.startDate
        self.endDate = schedule.endDate
        self.isAllDay = schedule.isAllDay
        self.cycleOption = schedule.cycleOption
        self.color = schedule.color
        self.location = schedule.location
        self.address = schedule.address
        self.description = schedule.description
    }
}
