//
//  CycleOption.swift
//  SnapPlan
//
//  Created by opfic on 3/28/25.
//

import Foundation

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
