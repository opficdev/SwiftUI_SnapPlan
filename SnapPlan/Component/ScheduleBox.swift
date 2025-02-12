//
//  ScheduleBox.swift
//  SnapPlan
//
//  Created by opfic on 1/21/25.
//

import SwiftUI

struct ScheduleBox: View {
    @Binding var scheulde: ScheduleData?
    @Binding var isChanging: Bool
    @State private var height: CGFloat
    @State private var isVisible = true
    
    init(height: CGFloat, isChanging: Binding<Bool>, schedule: Binding<ScheduleData?> = .constant(nil)) {
        self._height = State(initialValue: height)
        self._isChanging = isChanging
        self._scheulde = schedule
    }
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.macBlue, lineWidth: 2)
                    .frame(width: geometry.size.width - 4, height: height - 4)
                    .background(
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.macBlue.opacity(isVisible ? 0.8 : 0.5))
                        }
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
                    
                
                if isChanging {
                    VStack {
                        Circle()
                            .stroke(Color.macBlue, lineWidth: 2)
                            .frame(width: 12, height: 12)
                            .background(
                                Circle().fill(Color.timeLine)
                                    .frame(width: 12, height: 12)
                            )
                            .offset(x: geometry.size.width * 0.1, y: -6)
                    }
                    .frame(width: geometry.size.width, alignment: .leading)
                    
                    VStack {
                        Circle()
                            .stroke(Color.macBlue, lineWidth: 2)
                            .frame(width: 12, height: 12)
                            .background(
                                Circle().fill(Color.timeLine)
                                    .frame(width: 12, height: 12)
                            )
                            .offset(x: -geometry.size.width * 0.1, y: 6)
                    }
                    .frame(width: geometry.size.width, alignment: .trailing)
                }
            }
            .offset(x: 2, y: 2)
            .onTapGesture {
                if isChanging {
                    scheulde = nil
                }
            }
        }
    }
}

#Preview {
    ScheduleBox(
        height: 100,
        isChanging: .constant(false),
        schedule: .constant(nil)
    )
}
