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
    
    static func yyyyMMdd(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "ko_KR")
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
    
    static func getDateString(for date: Date, components: Set<Calendar.Component>, is12hoursFmt: Bool = true) -> String {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents(components, from: date)
        
        var dateString = ""

        if let year = dateComponents.year {
            dateString += "\(year)년 "
        }
        if let month = dateComponents.month {
            dateString += "\(month)월 "
        }
        if let day = dateComponents.day {
            dateString += "\(day)일 "
        }
        if components.contains(.hour) || components.contains(.minute) {
            if let hour = dateComponents.hour, let minute = dateComponents.minute {
                let formattedHour = is12hoursFmt ? (hour == 12 ? 12 : hour % 12) : hour
                let period = is12hoursFmt ? (hour < 12 ? "오전" : "오후") : ""
                dateString += "\(period) \(formattedHour):" + String(format: "%02d", minute) + " "
            }
        }
        if let second = dateComponents.second {
            dateString += "\(second)초 "
        }
        if let _ = dateComponents.weekday {
            dateString += DateFormatter.krWeekDay(from: date)
        }
        
        return dateString.trimmingCharacters(in: .whitespaces)
    }
    
    static func mmss(from time: TimeInterval) -> String {
        let minute = Int(time) / 60
        let second = Int(time) % 60
        return String(format: "%02d:%02d", minute, second)
    }
}
