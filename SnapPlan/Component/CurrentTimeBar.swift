//
//  CurrentTimeBar.swift
//  SnapPlan
//
//  Created by opfic on 1/14/25.
//

import SwiftUI

struct CurrentTimeBar: View {
    @State private var height: CGFloat
    @State private var showVerticalLine: Bool
    
    init(height: CGFloat, showVerticalLine: Bool) {
        self._height = State(initialValue: height)
        self._showVerticalLine = State(initialValue: showVerticalLine)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            if showVerticalLine {
                Rectangle()
                    .frame(width: 2, height: height)
                    .foregroundColor(showVerticalLine ? Color.timeBar : Color.gray)
            }
            Rectangle()
                .frame(height: 2)
                .foregroundStyle(showVerticalLine ? Color.timeBar : Color.gray)
        }
        .frame(height: height)
    }
}

#Preview {
    CurrentTimeBar(height: 20, showVerticalLine: true)
}
