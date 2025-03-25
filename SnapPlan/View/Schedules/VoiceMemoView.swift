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
        VStack(spacing: 100) {
            Text("음성 메모")
                .foregroundStyle(Color.gray)
                .bold()
            
//                HStack(spacing: 2) {
//                    ForEach(scheduleVM.audioLevels, id: \.self) { level in
//                        Rectangle()
//                            .fill(Color.timeBar)
//                            .frame(width: 4, height: level)
//                    }
//                    .frame(height: UIScreen.main.bounds.height * 0.2)
//                    .background(
//                        GeometryReader { proxy in
//                            Color.clear.onChange(of: proxy.size.width) { width in
//                                if UIScreen.main.bounds.width <= width {
//                                    scheduleVM.audioLevels.removeFirst()
//                                }
//                            }
//                        }
//                    )
//                }
//                .frame(maxWidth: .infinity, alignment: .trailing)
        
            
            ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 3)
                    .frame(width: circleRadius)
                RoundedRectangle(cornerRadius: circleRadius * (scheduleVM.isRecording ? 0.15 : 1))
                    .fill(Color.timeBar)
                    .frame(width: circleRadius * (scheduleVM.isRecording ? 0.5 : 0.8), height: circleRadius * (scheduleVM.isRecording ? 0.5 : 0.8)
                    )
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
    }
}

#Preview {
    VoiceMemoView()
        .environmentObject(ScheduleViewModel())
}
