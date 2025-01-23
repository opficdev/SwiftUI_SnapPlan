//
//  ScheduleData.swift
//  SnapPlan
//
//  Created by opfic on 1/17/25.
//

import Foundation

struct ScheduleData: Identifiable {
    let id = UUID()
    var title: String
    var timeLine: (Date, Date)
    var isChanging = false
    
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
}
