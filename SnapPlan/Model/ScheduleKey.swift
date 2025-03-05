//
//  ScheduleKey.swift
//  SnapPlan
//
//  Created by opfic on 3/5/25.
//
//  Firestore에서 데이터를 가져온 후, 앱에서 데이터를 저장할 시 딕셔너리의 키로 사용하기 위한 모델

import Foundation

struct ScheduleKey: Hashable {
    let startDate: Date
    let endDate: Date
}
