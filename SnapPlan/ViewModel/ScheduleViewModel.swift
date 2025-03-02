//
//  ScheduleViewModel.swift
//  SnapPlan
//
//  Created by opfic on 2/22/25.
//

import Foundation

class ScheduleViewModel: ObservableObject {
    @Published var title = ""
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var allDay = false
    @Published var cycleOption = ScheduleData.CycleOption.none
    @Published var location = ""
    @Published var address = ""
    @Published var description = ""
    @Published var color = 0
    
    func getSchedule() -> ScheduleData {
        return ScheduleData(
            title: title,
            timeLine: (startDate, endDate),
            allDay: allDay,
            cycleOption: cycleOption,
            location: location,
            description: description,
            color: color
        )
    }
    
    func setSchedule(schedule: ScheduleData) {
        title = schedule.title
        startDate = schedule.timeLine.0
        endDate = schedule.timeLine.1
        allDay = schedule.allDay
        cycleOption = schedule.cycleOption
        location = schedule.location
        description = schedule.description
        color = schedule.color
    }
    
    func setSchedule(startDate: Date) {
        title = ""
        self.startDate = startDate
        self.endDate = startDate.addingTimeInterval(1800)
        allDay = false
        cycleOption = .none
        location = ""
        description = ""
        color = 0
    }
}
