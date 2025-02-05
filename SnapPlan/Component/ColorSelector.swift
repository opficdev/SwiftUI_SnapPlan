//
//  ColorPicker.swift
//  SnapPlan
//
//  Created by opfic on 2/4/25.
//

import SwiftUI

struct ColorSelector: View {
    let colorArr = [
        Color.macBlue, Color.macPurple, Color.macPink, Color.macRed,
        Color.macOrange, Color.macYellow, Color.macGreen
    ]
    @Environment(\.dismiss) var dismiss
    @State private var height = CGFloat.zero
    @State private var colorWidth: CGFloat = UIScreen.main.bounds.width / 15
    @Binding var color: Int
    
    var body: some View {
        HStack {
            ForEach(Array(zip(colorArr.indices, colorArr)), id: \.1) { idx, color in
                RoundedRectangle(cornerRadius: 5)
                    .fill(color)
                    .frame(
                        width: self.color == idx ? colorWidth * 1.1 : colorWidth,
                        height: self.color == idx ? colorWidth * 1.1 : colorWidth)
                    .onTapGesture {
                        self.color = idx
                        dismiss()
                    }
                    .overlay(
                        ZStack {
                            if self.color == idx {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(UIColor.systemBackground))
                            }
                        }
                    )
            }
        }
        .padding()
        .background(
            GeometryReader { geometry in
                Color.clear.onAppear {
                    height = geometry.size.height
                }
            }
        )
        .presentationDragIndicator(.visible)
        .presentationDetents([.height(height)])
    }
}


#Preview {
    ColorSelector(
        color: .constant(0)
    )
}
