//
//  ScheduleBox.swift
//  SnapPlan
//
//  Created by opfic on 1/21/25.
//

import SwiftUI

struct ScheduleBox: View {
    @Binding var isChanging: Bool
    @State private var height: CGFloat
    @State private var isVisible = true
    
    init(height: CGFloat, isChanging: Binding<Bool>) {
        self._height = State(initialValue: height)
        self._isChanging = isChanging
    }
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.scheduleBox.opacity(isVisible ? 0.8 : 0.6))
                    .frame(height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.scheduleBox, lineWidth: 2)
                    )
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                            if isChanging {
                                withAnimation(.easeInOut(duration: 1.0)) {
                                    isVisible.toggle()
                                }
                            }
                        }
                    }
                    .onChange(of: isChanging) { value in
                        if !value {
                            isVisible = true
                        }
                    }
                
                VStack {
                    Circle()
                        .fill(Color.timeLine)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle().stroke(Color.scheduleBox, lineWidth: 2) // 테두리 추가
                        )
                        .offset(x: geometry.size.width * 0.1, y: -8)
                }
                .frame(width: geometry.size.width, alignment: .leading)
                    
                VStack {
                    Circle()
                        .fill(Color.timeLine)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle().stroke(Color.scheduleBox, lineWidth: 2) // 테두리 추가
                        )
                        .offset(x: -geometry.size.width * 0.1, y: 8)
                }
                .frame(width: geometry.size.width, alignment: .trailing)
                .offset(y: height - 16)
            }
            .offset(y: -8)
        }
    }
}

#Preview {
    ScheduleBox(
        height: 100,
        isChanging: .constant(false)
    )
}
