//
//  CustomCycleView.swift
//  SnapPlan
//
//  Created by opfic on 3/11/25.
//

import SwiftUI

struct CustomCycleView: View {
    @State private var num = 0
    @State private var kind = Calendar.Component.day
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Text("반복 주기")
                }
                HStack {
                    Text("반복")
                }
            }
            .listStyle(.inset)
            .overlay {
                Text("이벤트가 \(num) 마다 반복됩니다")
                    .foregroundStyle(Color.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.timeLine)
    }
}

#Preview {
    CustomCycleView()
}
