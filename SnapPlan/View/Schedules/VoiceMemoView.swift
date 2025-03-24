//
//  VoiceMemoView.swift
//  SnapPlan
//
//  Created by opfic on 3/18/25.
//

import SwiftUI

struct VoiceMemoView: View {
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    let circleRadius = UIScreen.main.bounds.width * 0.12
    
    var body: some View {
        ZStack {
            Color.timeLine.ignoresSafeArea()
            VStack {
                ZStack {
                    Circle()
                        .stroke(Color.gray, lineWidth: 3)
                        .frame(width: circleRadius)
                    RoundedRectangle(cornerRadius: circleRadius * (scheduleVM.isRecording ? 0.15 : 1))
                        .fill(Color.blue)
                        .frame(width: circleRadius * (scheduleVM.isRecording ? 0.5 : 0.8), height: circleRadius * (scheduleVM.isRecording ? 0.5 : 0.8)
                        )
                }
                .onTapGesture {
                    withAnimation {
                        if scheduleVM.isRecording {
//                            scheduleVM.stopRecord()
                        }
                        else {
//                            scheduleVM.startRecord()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.4)
    }
}

#Preview {
    VoiceMemoView()
        .environmentObject(ScheduleViewModel())
}
