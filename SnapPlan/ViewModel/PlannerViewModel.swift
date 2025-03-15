//
//  PlannerViewModel.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//  CalendarView와 TimeLineView에 사용되는 ViewModel

import SwiftUI
import Combine

final class PlannerViewModel: ObservableObject {
    @Published var today = Date()
    @Published var selectDate = Date() //  캘린더에서 선택된 날짜
    @Published var currentDate = Date() // 캘린더에서 보여주는 년도와 월
    @Published var calendarData = [[Date]]() // 캘린더에 표시할 날짜들 [[저번달], [이번달], [다음달]] 형태
    @Published var wasPast = false  //  새로운 selectDate가 기존 selectDate 이전인지 여부
    @Published var ChangedDateFromCalendarView = false   //  selectDate가 CalendarView에서 탭으로 변경되었는지 여부
    
    init() {
        startTimer()
        setCalendarData(date: today)
    }
    
    private var timerCancellable: AnyCancellable?
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }
    var daysOfWeek: [String] {
        return calendar.shortWeekdaySymbols
    }

    private func startTimer() {
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.today = Date()
            }
    }
    
    func getDateFromIndex(index: Int) -> Date {
        let componenets = calendar.dateComponents([.year, .month, .day], from: selectDate)
        let year = componenets.year!
        let month = componenets.month!
        let day = componenets.day!
        
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: index))!
    }
    
    /// 특정 Date 2개의 컴포넌트들을 서로 합친 Date를 반환
    func getMergedDate(for date1: Date, with date2: Date, forComponents: Set<Calendar.Component>, withComponents: Set<Calendar.Component>) -> Date {
        let date1Components = calendar.dateComponents(forComponents, from: date1)
        let date2Compoents = calendar.dateComponents(withComponents, from: date2)
        
        let year = date1Components.year ?? date2Compoents.year ?? 0
        let month = date1Components.month ?? date2Compoents.month ?? 0
        let day = date1Components.day ?? date2Compoents.day ?? 0
        let hour = date1Components.hour ?? date2Compoents.hour ?? 0
        let minute = date1Components.minute ?? date2Compoents.minute ?? 0
        
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }
    
    func isCollapsed(timeZoneHeight: CGFloat, gap: CGFloat, index: Int) -> Bool {
        let height = CGFloat(index) * (timeZoneHeight + gap)
        let offset = getOffsetFromDate(for: today, timeZoneHeight: timeZoneHeight, gap: gap)
        
        return height - timeZoneHeight <= offset && offset <= height + timeZoneHeight
    }
    
    func getDateString(for date: Date, components: Set<Calendar.Component>, is12hoursFmt: Bool = true) -> String {
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
            dateString += DateFormatter.krWeekDay.string(from: date)
        }
        
        return dateString.trimmingCharacters(in: .whitespaces)
    }
    
    func getOffsetFromDate(for date: Date, timeZoneHeight: CGFloat, gap: CGFloat) -> CGFloat {
        let startOfDay = calendar.startOfDay(for: date)
        return CGFloat(calendar.dateComponents([.minute], from: startOfDay, to: date).minute ?? 0) * (timeZoneHeight + gap) * 24 / 1440
    }
    
    func getFirstDayOfMonth(date: Date) -> Date {
        return calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
    }
    
    func getHours(is12hoursFmt: Bool) -> [TimeData] {
        let hours = Array(0...24)
        
        if is12hoursFmt {
            return hours.map { hour in
                if hour == 12 {
                    return TimeData(time: "정오")
                }
                if hour == 24 {
                    return TimeData(time: "12시", timePeriod: "오전")
                }
                return TimeData(time: "\(hour % 12)시", timePeriod: hour < 12 ? "오전" : "오후")
            }
        }

        return hours.map { TimeData(time: "\($0):00")}
    }

    func getWeekDates(date: Date) -> [Date] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: startOfWeek)
        }
    }
    
    func date(byAdding: Calendar.Component, value: Int, to: Date) -> Date? {
        return calendar.date(byAdding: byAdding, value: value, to: to)
    }
    
    func setCalendarData(date from: Date) {
        var data = [[Date]]()
        
        let lastMonthDay = calendar.date(byAdding: .month, value: -1, to: from)!
        let nextMonthDay = calendar.date(byAdding: .month, value: 1, to: from)!
        
        data.append(calendarDates(date: lastMonthDay))
        data.append(calendarDates(date: from))
        data.append(calendarDates(date: nextMonthDay))

        calendarData = data
    }
    
    func dateString(date: Date, component: Calendar.Component) -> String {
        return "\(calendar.component(component, from: date))"
    }
    
    func getCurrentMonthYear() -> String {
        if isSameDate(date1: currentDate, date2: today, components: [.year]) {
            return DateFormatter.krMonthFormatter.string(from: currentDate)
        }
        return DateFormatter.krMonthYearFormatter.string(from: currentDate)
    }
    
    func isSameDate(date1: Date, date2: Date, components: Set<Calendar.Component>) -> Bool {
        return calendar.dateComponents(components, from: date1) == calendar.dateComponents(components, from: date2)
    }
    
    func setDayForegroundColor(date: Date, colorScheme: ColorScheme) -> Color {
        if isSameDate(date1: date, date2: today, components: [.year, .month, .day]) {
            return Color.white
        }
        if !isSameDate(date1: date, date2: currentDate, components: [.year, .month]) {
            return Color.gray
        }
        return colorScheme == .light ? Color.black : Color.white
    }
    
    func calendarDates(date: Date) -> [Date] {
        var dates: [[Date]] = []

        // 이번 달의 첫 번째 날짜와 마지막 날짜 계산
        guard let range = calendar.range(of: .day, in: .month, for: date) else {
            return Array(dates.joined())
        }
        
        let firstDayOfMonth = getFirstDayOfMonth(date: date)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        // 이전 달의 날짜들 계산
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth),
           let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonth) {
            let previousMonthDays = Array(previousMonthRange.suffix(firstWeekday))
            var firstWeek: [Date] = []
            for day in previousMonthDays {
                firstWeek.append(calendar.date(byAdding: .day, value: day - previousMonthRange.count - 1, to: firstDayOfMonth)!)
            }
            
            if !firstWeek.isEmpty {
                dates.append(firstWeek)
            }
        }

        // 이번 달의 날짜들 추가
        for day in range {
            if dates.isEmpty || dates.last!.count == 7 { // 1일이 그 달의 첫번째 일요일일 때 or 그 주에 날짜가 더이상 들어갈 수 없을 때
                dates.append([Date]())
            }
            dates[dates.count - 1].append(calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth)!)
        }

        // 다음 달의 날짜들 추가
        let remainingDays = 42 - dates.flatMap { $0 }.count
        if remainingDays > 0, let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth){
            for day in 1...remainingDays {
                if dates.last!.count == 7 {
                    dates.append([Date]())
                }
                dates[dates.count - 1].append(calendar.date(byAdding: .day, value: day - 1, to: nextMonth)!)
            }
        }
        
        return Array(dates.joined())
    }
    
    deinit {
        timerCancellable?.cancel()
    }
}
