//
//  ScheduleData.swift
//  SnapPlan
//
//  Created by opfic on 1/17/25.
//

import Foundation

struct ScheduleData: Identifiable, Codable {
    let id: UUID //  UUID
    var title: String   // 일정 제목
    var startDate: Date // 일정 시작 날짜
    var endDate: Date   // 일정 종료 날짜
    var isChanging: Bool  // 일정 시간 변경 중인지 확인
    var isAllDay: Bool // 종일 일정 여부
    var cycleOption: CycleOption    // 일정 반복 주기
    var location: String // 일정 장소
    var address: String  // 장소에 대한 주소
    var description: String  // 일정 설명
    var color: Int  // 일정 색상(뷰에서 사용할 Color 배열의 인덱스임)
    
    init(
        id: UUID = UUID(),
        title: String = "",
        startDate: Date,
        endDate: Date,
        isChanging: Bool = false,
        isAllDay: Bool = false,
        cycleOption: CycleOption = .none,
        location: String = "",
        address: String = "",
        description: String = "",
        color: Int = 0
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isChanging = isChanging
        self.isAllDay = isAllDay
        self.cycleOption = cycleOption
        self.location = location
        self.address = address
        self.description = description
        self.color = color
    }
    
    enum CycleOption: String, Codable {
        case none = "none"  // 반복 없음
        case daily = "daily"    // 매일
        case weekdays = "weekdays"  // 평일
        case weekly = "weekly"  // 매주
        case biweekly = "biweekly"  // 2주마다
        case monthly = "monthly"    // 매달
        case yearly = "yearly"  // 매년
        case custom = "custom"  // 사용자 정의
    }
}
