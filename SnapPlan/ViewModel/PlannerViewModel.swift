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
    
    
    /// 해당 스케줄의 시작 offset과 duration을 반환
    func getTimeBoxOffset(from data: ScheduleData, timeZoneHeight: CGFloat, gap: CGFloat) -> (CGFloat, CGFloat) {
        let startOffset = getOffsetFromMiniute(for: data.timeLine.0, timeZoneHeight: timeZoneHeight, gap: gap)
        let endOffset = getOffsetFromMiniute(for: data.timeLine.1, timeZoneHeight: timeZoneHeight, gap: gap)
        
        return (startOffset, endOffset - startOffset)
    }
    
    func isCollapsed(timeZoneHeight: CGFloat, gap: CGFloat, index: Int) -> Bool {
        let height = CGFloat(index) * (timeZoneHeight + gap)
        let offset = getOffsetFromMiniute(for: today, timeZoneHeight: timeZoneHeight, gap: gap)
        
        return height - timeZoneHeight <= offset && offset <= height + timeZoneHeight
    }
    
    func getHoursAndMiniute(is12hoursFmt: Bool) -> String {
        let hour = calendar.component(.hour, from: today)
        let miniute = calendar.component(.minute, from: today)
        if is12hoursFmt {
            return "오" + (hour < 12 ? "전" : "후") + " \(hour % 12):" + String(format: "%02d", miniute)
        }
        return "\(hour):" + String(format: "%02d", miniute)
    }
    
    func getOffsetFromMiniute(for date: Date, timeZoneHeight: CGFloat, gap: CGFloat) -> CGFloat {
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
//        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
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
}
