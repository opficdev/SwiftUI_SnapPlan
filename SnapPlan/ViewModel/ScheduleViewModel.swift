//
//  ScheduleViewModel.swift
//  SnapPlan
//
//  Created by opfic on 2/22/25.
//
//  현재 설정중인 스케줄을 처리하는 뷰모델

import SwiftUI
import Combine
import AVKit

class ScheduleViewModel: ObservableObject {
    @Published var schedule: ScheduleData? = nil
    @Published var id: UUID? = nil
    @Published var title = ""
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var isAllDay = false
    @Published var cycleOption = ScheduleData.CycleOption.none
    @Published var location = ""
    @Published var address = ""
    @Published var description = ""
    @Published var color = 0
    
    @Published var photos: [UIImage] = []
    @Published var voiceMemo: AVAudioFile? = nil
    @Published var didChangedPhotosFromVM = false
    
    private var cancellable = Set<AnyCancellable>()
    private var audioRecorder: AVAudioRecorder? = nil
    
    init() {
        //  MARK: Combine으로 schedule 구조체 변수가 변경되면 자동으로 각 변수에 적용
        $schedule
            .sink { [weak self] newSchedule in
                if newSchedule == nil {
                    self?.id = nil  // schedule이 nil이면 id만 nil로 변경
                    self?.didChangedPhotosFromVM = false
                }
                else if let schedule = newSchedule {
                    self?.id = schedule.id
                    self?.title = schedule.title
                    self?.startDate = schedule.startDate
                    self?.endDate = schedule.endDate
                    self?.isAllDay = schedule.isAllDay
                    self?.cycleOption = schedule.cycleOption
                    self?.location = schedule.location
                    self?.address = schedule.address
                    self?.description = schedule.description
                    self?.color = schedule.color
                }
            }
            .store(in: &cancellable)
        //  MARK: Combine으로 각 변수들이 변경되면 자동으로 schedule 구조체 변수에 적용
        Publishers.CombineLatest4(
            $id,
            $title,
            $startDate,
            $endDate
        )
        .combineLatest(
            Publishers.CombineLatest3(
                $isAllDay,
                $cycleOption,
                $location
            ),
            Publishers.CombineLatest3(
                $address,
                $description,
                $color
            )
        )
        .map { [weak self] first, second, third -> ScheduleData? in
            
            let (id, title, startDate, endDate) = first
            let (isAllDay, cycleOption, location) = second
            let (address, description, color) = third
            
            // id가 nil이면 기존 schedule 유지, 그렇지 않으면 새로운 ScheduleData 생성
            return id == nil ? self?.schedule : ScheduleData(
                id: id!,
                title: title,
                startDate: startDate,
                endDate: endDate,
                isAllDay: isAllDay,
                cycleOption: cycleOption,
                location: location,
                address: address,
                description: description,
                color: color
            )
        }
        .assign(to: &$schedule)
    }
    
    func isCycleConfirm(date: Date, schedule: ScheduleData) -> Bool {
        if schedule.cycleOption == .daily {
            return true
        }
        else if schedule.cycleOption == .weekly {
            if isSameDate(date1: date, date2: schedule.startDate, components: [.weekday]) {
                return true
            }
        }
        else if schedule.cycleOption == .weekdays {
            if Calendar.current.component(.weekday, from: date) >= 2 && Calendar.current.component(.weekday, from: date) <= 6 {
                return true
            }
        }
        else if schedule.cycleOption == .biweekly {
            if isSameDate(date1: date, date2: schedule.startDate, components: [.weekday]) &&
                Calendar.current.component(.weekOfYear, from: date) % 2 == Calendar.current.component(.weekOfYear, from: schedule.startDate) % 2 {
                return true
            }
        }
        else if schedule.cycleOption == .monthly {
            if isSameDate(date1: date, date2: schedule.startDate, components: [.day]) {
                return true
            }
        }
        else if schedule.cycleOption == .yearly {
            if isSameDate(date1: date, date2: schedule.startDate, components: [.month, .day]) {
                return true
            }
        }
        else if schedule.cycleOption == .custom {
            
        }
 
        //  schedule.cycleOption == .none
        return false
    }
    
    private func isSameDate(date1: Date, date2: Date, components: Set<Calendar.Component>) -> Bool {
        return Calendar.current.dateComponents(components, from: date1) == Calendar.current.dateComponents(components, from: date2)
    }
    
    func startRecord() {
        let fileName = "\(Date()).m4a"
        let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        let settings = [
             AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
             AVSampleRateKey: 44100,
             AVNumberOfChannelsKey: 1,
             AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            self.audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            self.audioRecorder?.record()
            self.voiceMemo = try AVAudioFile(forReading: filePath)
        } catch {
            print("녹음 시작 실패: \(error.localizedDescription)")
        }
    }
    
    func stopRecord() -> AVAudioFile? {
        self.audioRecorder?.stop()
        return voiceMemo
    }
}
