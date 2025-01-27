//
//  TimeBar.swift
//  SnapPlan
//
//  Created by opfic on 1/14/25.
//

import SwiftUI

struct TimeBar: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var height: CGFloat
    @State private var showVerticalLine: Bool
    
    init(height: CGFloat, showVerticalLine: Bool) {
        self._height = State(initialValue: height)
        self._showVerticalLine = State(initialValue: showVerticalLine)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 0) {
                Group {
                    if showVerticalLine {
                        Rectangle()
                            .frame(width: 2, height: height)
                            .foregroundStyle(showVerticalLine ? Color.timeBar : Color.gray)
                    }
                    Rectangle()
                        .frame(height: showVerticalLine ? 2 : 1)
                        .foregroundStyle(showVerticalLine ? Color.timeBar : Color.gray)
                }
                .overlay {
                    if showVerticalLine {
                        Rectangle()
                            .stroke(Color.white, lineWidth: 0.5)
                    }
                }
            }
            if showVerticalLine {
                Rectangle()
                    .fill(Color.timeBar)
                    .frame(width: 4, height: 1.5)
                    .offset(x: 1)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    TimeBar(height: 20, showVerticalLine: true)
}
