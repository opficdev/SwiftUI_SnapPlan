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
    @State private var timeZoneSize = CGSize()
    @State private var gap: CGFloat = UIScreen.main.bounds.width / 24    //  이거 조절해서 간격 조절
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    HStack(spacing: 0) {
                        VStack(alignment: .trailing, spacing: gap) {
                            ForEach(viewModel.getHours(is12hoursFmt: is12TimeFmt), id: \.self) { hour in
                                Text(hour)
                                    .font(.callout)
                                    .frame(width: screenWidth / 6)
                                    .background(
                                        GeometryReader { geometry in
                                            Color.white.onAppear {
                                                timeZoneSize = geometry.size
                                            }
                                        }
                                    )
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(viewModel.getWeekDates(date: viewModel.currentDate), id: \.self) { day in
                                    VStack(spacing: gap) {
                                        ForEach(viewModel.getHours(is12hoursFmt: is12TimeFmt), id: \.self) { hour in
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
