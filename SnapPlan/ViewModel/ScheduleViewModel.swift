//
//  ScheduleViewModel.swift
//  SnapPlan
//
//  Created by opfic on 2/22/25.
//
//  현재 설정중인 스케줄을 처리하는 뷰모델

import Foundation
import Combine

class ScheduleViewModel: ObservableObject {
    @Published var schedule: ScheduleData? = nil
    @Published var id: UUID? = nil
    @Published var title = ""
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var allDay = false
    @Published var cycleOption = ScheduleData.CycleOption.none
    @Published var location = ""
    @Published var address = ""
    @Published var description = ""
    @Published var color = 0
    
    
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        //  MARK: Combine으로 schedule 구조체 변수가 변경되면 자동으로 각 변수에 적용
        $schedule
            .sink { [weak self] newSchedule in
                if newSchedule == nil {
                    self?.id = nil  // schedule이 nil이면 id만 nil로 변경
                }
                else if let schedule = newSchedule {
                    self?.id = schedule.id
                    self?.title = schedule.title
                    self?.startDate = schedule.startDate
                    self?.endDate = schedule.endDate
                    self?.allDay = schedule.allDay
                    self?.cycleOption = schedule.cycleOption
                    self?.location = schedule.location
                    self?.address = schedule.address
                    self?.description = schedule.description
                    self?.color = schedule.color
                }
            }
            .store(in: &cancellable)
        //  MARK: Combine으로 각 변수들이 변경되면 자동으로 schedule 구조체 변수에 적용
        Publishers.CombineLatest3(
            $id,
            $title,
            $startDate
        )
        .combineLatest(
            Publishers.CombineLatest3(
                $endDate,
                $allDay,
                $cycleOption
            ),
            Publishers.CombineLatest4(
                $location,
                $address,
                $description,
                $color
            )
        )
        .map { [weak self] first, second, third -> ScheduleData? in
            guard let self = self, let currentSchedule = self.schedule else {
                return nil
            }
            
            let (id, title, startDate) = first
            let (endDate, allDay, cycleOption) = second
            let (location, description, address, color) = third
            
            // id가 nil이면 기존 schedule 유지, 그렇지 않으면 새로운 ScheduleData 생성
            return id == nil ? currentSchedule : ScheduleData(
                id: id!,
                title: title,
                startDate: startDate,
                endDate: endDate,
                allDay: allDay,
                cycleOption: cycleOption,
                location: location,
                address: address,
                description: description,
                color: color
            )
        }
        .assign(to: &$schedule)
    }
}
