//
//  SearchScheduleView.swift
//  SnapPlan
//
//  Created by opfic on 4/26/25.
//

import SwiftUI
import UIKit

struct SearchScheduleView: View {
    @EnvironmentObject var plannerVM: PlannerViewModel
    @EnvironmentObject var firebaseVM: FirebaseViewModel
    @State private var keyword = ""
    @State private var showCancelButton = true
    @State private var schedulesByDate: [Date: [ScheduleData]] = [:]
    @FocusState private var keywordFocus: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 0) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.callout)
                        .padding(8)
                    TextField(text: $keyword) {
                        Text("일정 제목, 장소, 설명")
                            .foregroundColor(.gray)
                            .font(.callout)
                    }
                    .focused($keywordFocus)
                    if !keyword.isEmpty {
                        Button(action: {
                            keyword = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.callout)
                                .padding(8)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.15))
                )
                
                if showCancelButton {
                    Button(action:{
                        keywordFocus = false
                        keyword = ""
                    }) {
                        Text("취소")
                            .foregroundColor(.blue)
                            .font(.callout)
                    }
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            let keys = Array(schedulesByDate.keys).sorted()
            List(Array(zip(keys.indices, keys)), id: \.1) { index, key in
                let schedules = schedulesByDate[key]!
                let components: Set<Calendar.Component> = plannerVM.isSameDate(
                    date1: plannerVM.today,
                    date2: key, components: [.year]) ? [.month, .day] : [.year, .month, .day]
                    Section(
                        header: Text("\(plannerVM.getDateString(for: key, components: components))-\(DateFormatter.krWeekDay(from: key))요일")
                    ) {
                        ForEach(schedules, id: \.id) { schedule in
                            HStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.colorArray[schedule.color])
                                    .frame(width: 5)
                                VStack(alignment: .leading) {
                                    Text(schedule.title)
                                        .foregroundStyle(Color.primary)
                                        .bold()
                                        .lineLimit(1)
                                    HStack(spacing: 0) {
                                        if !schedule.address.isEmpty {
                                            Image(systemName: "location.circle")
                                                .font(.caption2)
                                                .padding(.trailing, 4)
                                        }
                                        Text(schedule.address)
                                            .lineLimit(1)
                                            .font(.caption2)
                                    }
                                    .foregroundStyle(Color.gray)
                                }
                                Spacer()
                                VStack {
                                    Text(plannerVM.getDateString(for: schedule.startDate, components: [.hour, .minute]))
                                    let components: Set<Calendar.Component> = plannerVM.isSameDate(
                                        date1: schedule.startDate,
                                        date2: schedule.endDate,
                                        components: [.year]) ? [.hour, .minute] : [.year, .month, .day]
                                    Text(plannerVM.getDateString(for: schedule.endDate, components: components))
                                }
                                .foregroundStyle(Color.gray)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
            }
            .listStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.calendar)
        .onAppear {
            keywordFocus = true
            showCancelButton = true
        }
        .onChange(of: keywordFocus) { value in
            withAnimation {
                showCancelButton = value
            }
        }
        .onChange(of: keyword) { value in
            if value.isEmpty {
                schedulesByDate = [:]
                return
            }
            schedulesByDate = Dictionary(grouping: Array(firebaseVM.schedules.values).filter { scheduleData in
                scheduleData.title.localizedCaseInsensitiveContains(value) ||
                scheduleData.location.localizedCaseInsensitiveContains(value) ||
                scheduleData.description.localizedCaseInsensitiveContains(value)
            }) { scheduleData in
                let components = Calendar.current.dateComponents([.year, .month, .day], from: scheduleData.startDate)
                return Calendar.current.date(from: components)!
            }
        }
        .onTapGesture {
            keywordFocus = false
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("일정")
                    .font(.headline)
                    .bold()
            }
        }
    }
}
