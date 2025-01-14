//
//  TimeData.swift
//  SnapPlan
//
//  Created by opfic on 1/7/25.
//

import Foundation

struct TimeData: Identifiable {
    let id: UUID
    let time: String
    let timePeriod: String
    
    init(time: String, timePeriod: String = "") {
        self.id = UUID()
        self.time = time
        self.timePeriod = timePeriod
    }
}
