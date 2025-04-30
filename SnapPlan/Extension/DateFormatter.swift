//
//  DateFormatter.swift
//  SnapPlan
//
//  Created by opfic on 2/6/25.
//

import Foundation

extension DateFormatter {
    static func krMonth(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "M월"
        return fmt.string(from: date)
    }
    
    static func krMonthYear(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy년 M월"
        return fmt.string(from: date)
    }
    
    static func krWeekDay(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "E"
        return fmt.string(from: date)
    }
    
    static func mmss(from time: TimeInterval) -> String {
        let minute = Int(time) / 60
        let second = Int(time) % 60
        return String(format: "%02d:%02d", minute, second)
    }
    
    static let yyyyMMdd = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt    
    }()
}
