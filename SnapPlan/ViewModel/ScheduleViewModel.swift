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
    @Published var audioLevels: [CGFloat] = []
    @Published var isRecording = false
    @Published var recordingTime = 0.0
    @Published var didChangedPhotosFromVM = false
    
    private var cancellable = Set<AnyCancellable>()
    private var audioRecorder: AVAudioRecorder? = nil
    private var timer: Timer? = nil
    private var recordedFileURL: URL? = nil
    
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
             try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
             try AVAudioSession.sharedInstance().setActive(true)
         } catch {
             print("AudioSession 설정 실패: \(error.localizedDescription)")
             return
         }

        do {
            self.audioLevels.removeAll()
            self.audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            self.audioRecorder?.isMeteringEnabled = true
            self.audioRecorder?.record()
            self.recordedFileURL = filePath
            self.startMonitoring()
        } catch {
            print("녹음 시작 실패: \(error.localizedDescription)")
            return
        }
        isRecording = true
    }

    func stopRecord() {
        guard let recordedFileURL else {
            print("URL 에러: \(URLError(.badURL).localizedDescription)")
            return
        }
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("AudioSession 비활성화 실패: \(error.localizedDescription)")
        }
        
        if FileManager.default.fileExists(atPath: recordedFileURL.path) {
            print("녹음 파일 존재: \(recordedFileURL.path)")
        } else {
            print("녹음 파일이 존재 X")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            do {
                self.voiceMemo = try AVAudioFile(forReading: recordedFileURL)
                self.isRecording = false
                self.stopMonitoring()
                print("AVAudioFile 생성 성공")
            } catch {
                print("녹음 파일 열기 실패: \(error.localizedDescription)")
            }
        }
    }
    
    private func startMonitoring() {
        self.recordingTime = 0
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.audioRecorder?.updateMeters()
            //  audioRecorder.averagePower(forChannel: 0)은 -160 ~ 0 사이의 값
            //  일반적인 음성 녹음에서는 -60 ~ 0 이 나옴
            //  이것을 0 ~ 1 사이의 값으로 변환
            let power = max(CGFloat(self.audioRecorder?.averagePower(forChannel: 0) ?? 0), -60) + 60 //  [0, 60] 범위
            self.audioLevels.append(max(0, power / 60)) //  [0, 1] 범위
            
            self.recordingTime += 0.1
            if 60 * 60 <= self.recordingTime {
                self.stopRecord()
            }
        }
    }
    
    private func stopMonitoring() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
