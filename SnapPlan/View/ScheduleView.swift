//
//  ScheduleView.swift
//  SnapPlan
//
//  Created by opfic on 1/1/25.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject private var viewModel: PlannerViewModel
    @Environment(\.colorScheme) var colorScheme
    let screenWidth = UIScreen.main.bounds.width
        
    @State private var is12TimeFmt = true  //  후에 firebase에 저장 및 가져와야함
    @State private var timeZoneSize = CGSizeZero
    @State private var gap: CGFloat = UIScreen.main.bounds.width / 24    //  이거 조절해서 간격 조절
    @State private var selection = 0
    
    var body: some View {
        ZStack {
            Color.scheduleBackground.ignoresSafeArea()
            let calendarData = viewModel.calendarData[1]
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(is12TimeFmt ? "12시간제" : "24시간제")
                        .frame(width: screenWidth / 7)
                        .font(.caption)
                        .onTapGesture {
                            is12TimeFmt.toggle()
                        }
                    
                    TabView(selection: $selection) {
                        ForEach(Array(zip(calendarData.indices, calendarData)), id: \.1) { idx, date in
                            HStack {
                                Text(viewModel.dateString(date: date, component: .day))
                                    .font(.callout)
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(
                                            viewModel.isSameDate(date1: date, date2: viewModel.today, components: [.year, .month, .day]) ? Color.pink : Color.gray.opacity(0.5)
                                        )
                                        .frame(width: screenWidth / 14, height: screenWidth / 14)
                                    Text("\(DateFormatter.krWeekDay.string(from: date))")
                                        .font(.callout)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.white)
                                }
                            }
                            .tag(idx)
                        }
                        .frame(width: screenWidth - timeZoneSize.width, height: screenWidth / 10)
                    }
                    .frame(width: screenWidth - timeZoneSize.width, height: screenWidth / 10)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                .background(Color.calendarBackground)
                
                ScrollView(showsIndicators: false) {
                    HStack(spacing: 0) {
                        VStack(alignment: .trailing, spacing: gap) {
                            ForEach(viewModel.getHours(is12hoursFmt: is12TimeFmt)) { hour in
                                HStack(spacing: 4) {
                                    Group {
                                        Text(hour.timePeriod)
                                        Text(hour.time)
                                    }
                                    .font(.caption)
                                    .padding(.trailing, 2)
                                    .foregroundStyle(Color.gray)
                                }
                                .frame(width: screenWidth / 7, alignment: .trailing)
                                .background(
                                    GeometryReader { geometry in
                                        Color.clear.onAppear {
                                            if timeZoneSize == CGSizeZero {
                                                timeZoneSize = geometry.size
                                            }
                                        }
                                    }
                                )
                            }
                        }
                        .border(Color.gray.opacity(0.5))
                           
                        TabView(selection: $selection) {
                            ForEach(Array(zip(calendarData.indices, calendarData)), id: \.1) { idx, date in
                                VStack(spacing: gap) {
                                    ForEach(1...24, id: \.self) { index in
                                        ZStack {
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(Color.gray.opacity(0.5))
                                        }
                                        .frame(height: timeZoneSize.height)
                                    }
                                }
                                .tag(idx)
                                .onAppear {
                                    viewModel.selectDate = date
                                }
                            }
                            .border(Color.gray.opacity(0.5))
                            .frame(width: screenWidth - timeZoneSize.width)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .border(Color.gray.opacity(0.5))
                    }
                }
            }
            .onAppear {
               selection = calendarData.firstIndex(where: {
                   viewModel.isSameDate(date1: $0, date2: viewModel.selectDate, components: [.year, .month, .day]) }
               )!
            }
            .onChange(of: viewModel.selectDate) { newDate in
                selection = calendarData.firstIndex(where: {
                    viewModel.isSameDate(date1: $0, date2: newDate, components: [.year, .month, .day]) }
                )!
            }
        }
    }
}

#Preview {
    ScheduleView()
        .environmentObject(PlannerViewModel())
}
