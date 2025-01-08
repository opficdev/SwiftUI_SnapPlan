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
    @State private var scrollOffset = CGFloat.zero
    
    var body: some View {
        ZStack {
            Color.scheduleBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                let calendarData = viewModel.calendarData.flatMap {$0}
                HStack(spacing: 0) {
                    Text(is12TimeFmt ? "12시간제" : "24시간제")
                        .frame(width: screenWidth / 7)
                        .font(.caption)
                        .onTapGesture {
                            is12TimeFmt.toggle()
                        }
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(Array(zip(calendarData.indices, calendarData)), id: \.0) { idx, date in
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
                                    .id(idx)
                                }
                                .frame(width: screenWidth - timeZoneSize.width, height: screenWidth / 10)
                            }
                            .offset(x: -scrollOffset)
                        }
                        .frame(width: screenWidth - timeZoneSize.width, height: screenWidth / 10)
                        .disabled(true)
                    }
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
                        
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 0) {
                                    ForEach(Array(zip(calendarData.indices, calendarData)), id: \.0) { idx, date in
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
                                        .id(idx)
                                    }
                                    .border(Color.gray.opacity(0.5))
                                    .frame(width: screenWidth - timeZoneSize.width)
                                }
                                .background(GeometryReader {
                                    Color.clear.preference(key: SyncScrollViewKey.self,
                                                           value: -$0.frame(in: .named("timeScroll")).origin.x)
                                })
                                .onPreferenceChange(SyncScrollViewKey.self) { value in
                                    scrollOffset = value
                                }
                            }
                            .onAppear {
                                let index = calendarData.firstIndex(where: { viewModel.isSameDate(date1: $0, date2: viewModel.selectDate, components: [.year, .month, .day]) })!
                                proxy.scrollTo(index, anchor: .center)
                            }
                            .coordinateSpace(name: "timeScroll")
                            .border(Color.gray.opacity(0.5))
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ScheduleView()
        .environmentObject(PlannerViewModel())
}
