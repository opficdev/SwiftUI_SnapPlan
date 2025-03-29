//
//  VoiceMemoView.swift
//  SnapPlan
//
//  Created by opfic on 3/18/25.
//

import SwiftUI

struct VoiceMemoView: View {
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @Environment(\.dismiss) var dismiss
    let circleRadius = UIScreen.main.bounds.width * 0.12
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("음성 메모")
                    .foregroundStyle(Color.gray)
                    .bold()
                //
                Text("\(String(format: "%.1f", scheduleVM.recordingTime)) / 30:00")
                    .bold()
            }
            
                HStack(spacing: 2) {
                    let audioLevels = scheduleVM.audioLevels
                    ForEach(Array(zip(audioLevels.indices, audioLevels)), id: \.1) { _, level in
                        Rectangle()
                            .fill(Color.timeBar)
                            .frame(width: 2, height: min(100, max(1, level * 100)))
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.2)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.onChange(of: proxy.size.width) { width in
                                if UIScreen.main.bounds.width <= width {
                                    scheduleVM.audioLevels.removeFirst()
                                }
                            }
                        }
                    )
                }
                .frame(width: UIScreen.main.bounds.width, height: 100, alignment: .trailing)
            
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 3)
                    .frame(width: circleRadius)
                RoundedRectangle(cornerRadius: circleRadius * (scheduleVM.isRecording ? 0.15 : 1))
                    .fill(Color.timeBar)
                    .frame(width: circleRadius * (scheduleVM.isRecording ? 0.5 : 0.8), height: circleRadius * (scheduleVM.isRecording ? 0.5 : 0.8))
            }
            .onTapGesture {
                withAnimation {
                    if scheduleVM.isRecording {
                        scheduleVM.stopRecord()
                        dismiss()
                    }
                    else {
                        scheduleVM.startRecord()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.4)
        .presentationDetents([.fraction(0.4)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    VoiceMemoView()
        .environmentObject(ScheduleViewModel())
}
