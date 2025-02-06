//
//  DateFormatter.swift
//  SnapPlan
//
//  Created by opfic on 2/6/25.
//

import Foundation

extension DateFormatter {
    static let krMonthFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "M월" // 한국어 형식의 월 포맷
        return fmt
    }()
    
    static let krMonthYearFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy년 M월" // 한국어 형식의 연월 포맷
        return fmt
    }()
    
    static let krWeekDay: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "E"
        return fmt
    }()
    
    static let yyyyMMdd: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt
    }()
}
