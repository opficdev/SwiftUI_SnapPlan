//
//  Schedule.swift
//  SnapPlan
//
//  Created by opfic on 2/11/25.
//

import Foundation

extension ScheduleData: Equatable {
    static func == (lhs: ScheduleData, rhs: ScheduleData) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.startDate == rhs.startDate &&
               lhs.endDate == rhs.endDate &&
               lhs.cycleOption == rhs.cycleOption &&
               lhs.location == rhs.location &&
               lhs.description == rhs.description &&
               lhs.color == rhs.color
    }
}
