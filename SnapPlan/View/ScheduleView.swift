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
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(is12TimeFmt ? "12시간제" : "24시간제")
                    .font(.caption)
                    .onTapGesture {
                        is12TimeFmt.toggle()
                    }
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(viewModel.calendarData.flatMap {$0}, id: \.self) { day in
                                HStack {
                                    Text(viewModel.dateString(date: day, component: .day))
                                    Text("(\(viewModel.dateString(date: day, component: .weekday)))")
                                }
                            }
                            .frame(width: screenWidth - timeZoneSize.width, height: screenWidth / 10)
                        }
                    }
                    .frame(width: screenWidth - timeZoneSize.width, height: screenWidth / 10)
                    .disabled(true)
                }
            }
            .background(Color.gray.opacity(0.1))
            
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
                                    Color.white.onAppear {
                                        if timeZoneSize == CGSizeZero {
                                            timeZoneSize = geometry.size
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .border(Color.black)
                    
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(viewModel.calendarData.flatMap {$0}, id: \.self) { day in
                                    VStack(spacing: gap) {
                                        ForEach(1...24, id: \.self) { index in
                                            ZStack {
                                                Rectangle()
                                                    .frame(height: 1)
                                            }
                                            .frame(height: timeZoneSize.height)
                                        }
                                    }
                                }
                                .border(Color.black)
                                .frame(width: screenWidth - timeZoneSize.width)
                            }
                        }
                        .border(Color.black)
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
