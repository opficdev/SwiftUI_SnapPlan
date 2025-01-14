//
//  CurrentTimeBar.swift
//  SnapPlan
//
//  Created by opfic on 1/14/25.
//

import SwiftUI

struct CurrentTimeBar: View {
    @State private var height: CGFloat
    
    init(height: CGFloat) {
        self._height = State(initialValue: height)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .frame(width: 2, height: height)
                .foregroundColor(.pink)
            Rectangle()
                .frame(height: 2)
                .foregroundStyle(.pink)
        }
    }
}

#Preview {
    CurrentTimeBar(height: 20)
}
