//
//  TimeView.swift
//  SnapPlan
//
//  Created by opfic on 12/31/24.
//

import SwiftUI

struct CalendarView: View {
    @StateObject var viewModel = CalendarViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    @State private var spacerWidth: CGFloat = 0
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        VStack(spacing: 0) {
            Group {
                HStack {
                    HStack(spacing: 0) {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth / 18)
                            .foregroundStyle(Color.gray)
                            .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 8)) //  월 보여주는거 때문에 16 - 8
                            .onTapGesture {
                                
                            }
                        HStack(spacing: 4) {
                            Text(viewModel.getSelectedMonthYear())
                                .font(.title)
                                .bold()
                            Image(systemName: "chevron.\(viewModel.showFullCalendar ? "up" : "down")")
                                .foregroundStyle(
                                    Color.black.opacity(
                                        viewModel.showFullCalendar ? 1 : 0.5
                                    )
                                )
                        }
                        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    Color.gray.opacity(
                                        viewModel.showFullCalendar ? 0.3 : 0
                                    )
                                )
                        )
                        .onTapGesture {
                            viewModel.showFullCalendar.toggle()
                        }
                        Spacer()
                        
                        Group {
                            Text(viewModel.dateString(date: Date(), component: .day))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.white)
                                .frame(width: screenWidth / 14, height: screenWidth / 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            viewModel.dateCompare(date1: Date(), date2: viewModel.selectDate, components: [.year, .month, .day]) ? Color.gray.opacity(0.5) : Color.pink
                                        )
                                )
                                .onTapGesture{
                                    viewModel.selectDate = Date()
                                }
                        }
                    }
                    .frame(width: screenWidth - 2 * spacerWidth)
                }
                .frame(maxWidth: .infinity)
                
                if viewModel.showFullCalendar {
                    HStack {
                        ForEach(viewModel.daysOfWeek, id: \.self) { day in
                            Spacer()
                            Text(day)
                                .foregroundStyle(Color.gray)
                                .font(.caption)
                            Spacer()
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onAppear {
                                            spacerWidth = geometry.size.width
                                        }
                                    }
                                )
                        }
                    }
                    .padding(.vertical, 8)
                    .onAppear {
                        if !viewModel.didShowFullCalendar {
                            viewModel.didShowFullCalendar = true
                            viewModel.showFullCalendar = false
                        }
                    }
                
                    ScrollView(showsIndicators: false) {
                        ForEach(viewModel.calendarDates(), id: \.self) { week in
                            HStack(spacing: 0) {
                                ForEach(week, id: \.self) { date in
                                    Spacer()
                                    ZStack {
                                        if viewModel.dateCompare(date1: date, date2: viewModel.selectDate, components: [.year, .month, .day]) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(
                                                    Color.gray.opacity(0.5)
                                                )
                                                .frame(width: screenWidth / 10, height: screenWidth / 10)
                                        }
                                        
                                        if viewModel.dateCompare(date1: date, date2: Date(), components: [.year, .month, .day]) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.pink)
                                                .frame(width: screenWidth / 12, height: screenWidth / 12)
                                        }
                                            
                                        Text(viewModel.dateString(date: date, component: .day))
                                            .font(.subheadline)
                                            .foregroundStyle(viewModel.setDayForegroundColor(date: date, colorScheme: colorScheme))
                                            .frame(width: screenWidth / 10, height: screenWidth / 10)
                                            .onTapGesture {
                                                viewModel.selectDate = date
                                            }
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
            .background(Color.gray.opacity(0.1))
            
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    
                }
            }
        }
    }
}

#Preview {
    CalendarView()
}

