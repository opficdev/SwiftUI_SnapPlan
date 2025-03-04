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
    
    func getSchedule(id: UUID?) -> ScheduleData {
        return ScheduleData(
            id: id == nil ? UUID() : id!,
            title: title,
            startDate: startDate,
            endDate: endDate,
            allDay: allDay,
            cycleOption: cycleOption,
            location: location,
            description: description,
            color: color
        )
    }
    
    func setSchedule(schedule: ScheduleData) {
        title = schedule.title
        startDate = schedule.startDate
        endDate = schedule.endDate
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
