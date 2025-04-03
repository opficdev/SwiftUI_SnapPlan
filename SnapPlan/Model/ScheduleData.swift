//
//  ScheduleData.swift
//  SnapPlan
//
//  Created by opfic on 1/17/25.
//

import Foundation
import AVKit

struct ScheduleData: Identifiable {
    let id: UUID //  UUID
    var title: String   // 일정 제목
    var startDate: Date // 일정 시작 날짜
    var endDate: Date   // 일정 종료 날짜
    var isChanging: Bool  // 일정 시간 변경 중인지 확인
    var isAllDay: Bool // 종일 일정 여부
    var cycleOption: CycleOption    // 일정 반복 주기
    var color: Int  // 일정 색상(뷰에서 사용할 Color 배열의 인덱스임)
    var voiceMemo: AVAudioFile?  // 음성 메모
    var photos: [ImageAsset]    // 사진
    var location: String
    var address: String  // 장소에 대한 주소
    var description: String  // 일정 설명
    var memoState: StorageState = .initial   // 음성 메모가 다운로드 되었는지 확인
    var photosState: StorageState = .initial  // 사진이 다운로드 되었는지 확인
    
    init(
        id: UUID = UUID(),
        title: String = "",
        startDate: Date,
        endDate: Date,
        isChanging: Bool = false,
        isAllDay: Bool = false,
        cycleOption: CycleOption = .none,
        color: Int = 0,
        voiceMemo: AVAudioFile? = nil,
        photos: [ImageAsset] = [],
        location: String = "",
        address: String = "",
        description: String = ""
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isChanging = isChanging
        self.isAllDay = isAllDay
        self.cycleOption = cycleOption
        self.color = color
        self.voiceMemo = voiceMemo
        self.photos = photos
        self.location = location
        self.address = address
        self.description = description
    }
    
    init(schedule: CodableScheduleData, voiceMemo: AVAudioFile? = nil, photos: [ImageAsset] = []) {
        self.id = schedule.id
        self.title = schedule.title
        self.startDate = schedule.startDate
        self.endDate = schedule.endDate
        self.isChanging = false
        self.isAllDay = schedule.isAllDay
        self.cycleOption = schedule.cycleOption
        self.color = schedule.color
        self.voiceMemo = voiceMemo
        self.photos = photos
        self.location = schedule.location
        self.address = schedule.address
        self.description = schedule.description
    }
}
