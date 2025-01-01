//
//  CalendarViewModel.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//  MonthView와 TimeView에 사용되는 ViewModel

import SwiftUI

final class CalendarViewModel: ObservableObject {
    private let today = Date()
    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        return calendar
    }
    var daysOfWeek: [String] {
        return calendar.shortWeekdaySymbols
    }
    @Published var selectDate = Date() //  캘린더에서 선택된 날짜
    @Published var showFullCalendar = true // 전체 달력을 보여줄지 여부
    @Published var didShowFullCalendar = false
    // MARK: didShowFullCalendar의 설명
    // MARK: TimeView에서 가장 상단에 있는 뷰의 너비가 정하기 위해서
    // MARK: 최초 한번은 월 단위 캘린더가 뷰에 나와야 한다.
    // MARK: 이때 사용자 입장에서는 캘린더를 펴지 않았는데도 불구하고 뷰에 표시되어 있으면 이상하므로
    // MARK: 해당 상황을 제어하기 위한 변수이다.
    
    func dateString(date: Date, component: Calendar.Component) -> String {
        return "\(calendar.component(component, from: date))"
    }
    
    func getSelectedMonthYear() -> String {
        if calendar.dateComponents([.year], from: selectDate) == calendar.dateComponents([.year], from: today) {
            return DateFormatter.krMonthFormatter.string(from: selectDate)
        }
        return DateFormatter.krMonthYearFormatter.string(from: selectDate)
    }
    
    func dateCompare(date1: Date, date2: Date, components: Set<Calendar.Component>) -> Bool {
        return calendar.dateComponents(components, from: date1) == calendar.dateComponents(components, from: date2)
    }
    
    func setDayForegroundColor(date: Date, colorScheme: ColorScheme) -> Color {
        if dateCompare(date1: date, date2: today, components: [.year, .month, .day]) {
            return Color.white
        }
        if !dateCompare(date1: date, date2: selectDate, components: [.year, .month]) {
            return Color.gray
        }
        return colorScheme == .light ? Color.black : Color.white
    }
    
    func calendarDates() -> [[Date]] {
        var dates: [[Date]] = []

        // 이번 달의 첫 번째 날짜와 마지막 날짜 계산
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectDate)),
              let range = calendar.range(of: .day, in: .month, for: selectDate) else { return dates }
        
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
        var remainingDays = 49 - dates.flatMap { $0 } .count
        if remainingDays >= 7 { remainingDays -= 7 }
        if remainingDays > 0, let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDayOfMonth){
            for day in 1...remainingDays {
                if dates.last!.count == 7 {
                    dates.append([Date]())
                }
                dates[dates.count - 1].append(calendar.date(byAdding: .day, value: day - 1, to: nextMonth)!)
            }
        }

        return dates
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
}
