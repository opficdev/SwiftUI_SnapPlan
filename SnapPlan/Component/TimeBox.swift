//
//  TimeBox.swift
//  SnapPlan
//
//  Created by opfic on 1/21/25.
//

import SwiftUI

struct TimeBox: View {
    @Binding var isChanging: Bool
    @State private var isVisible = true
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cyan.opacity(isVisible ? 0.4 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.cyan, lineWidth: 2)
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
                
                VStack {
                    VStack {
                        Circle()
                            .fill(Color.timeLine)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle().stroke(Color.cyan, lineWidth: 2) // 테두리 추가
                            )
                            .offset(x: geometry.size.width * 0.1, y: -8)
                    }
                    .frame(width: geometry.size.width, alignment: .leading)
                    
                    Spacer()
                    VStack {
                        Circle()
                            .fill(Color.timeLine)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle().stroke(Color.cyan, lineWidth: 2) // 테두리 추가
                            )
                            .offset(x: -geometry.size.width * 0.1, y: 8)
                    }
                    .frame(width: geometry.size.width, alignment: .trailing)
                }
            }
        }
    }
}

#Preview {
    TimeBox(isChanging: .constant(false))
}
