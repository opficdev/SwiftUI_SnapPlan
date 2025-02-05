//
//  ColorPicker.swift
//  SnapPlan
//
//  Created by opfic on 2/4/25.
//

import SwiftUI
import SwiftUIIntrospect

struct ColorPicker: View {
    let colorArr = [
        Color.macBlue, Color.macPurple, Color.macPink, Color.macRed,
        Color.macOrange, Color.macYellow, Color.macGreen
    ]
    @Binding var color: Int
    var body: some View {
        HStack {
            ForEach(Array(zip(colorArr.indices, colorArr)), id: \.1) { idx, color in
                RoundedRectangle(cornerRadius: 5)
                    .fill(color)
                    .frame(width: 20, height: 20)
                    .onTapGesture {
                        self.color = idx
                    }
            }
        }
//        .introspect(.popover, on: .iOS(.v16, .v17, .v18)) { popover in   //  UIPopoverPresentationController
//            popover.permittedArrowDirections = []
//        }
    }
}


struct tentView: View {

    enum PopoverTarget {
        case text1
        case text2
        case text3

        var anchorForPopover: UnitPoint {
            switch self {
            case .text1: .top
            case .text2: .bottom
            case .text3: .bottom
            }
        }
    }

    @State private var popoverTarget: PopoverTarget?
    @Namespace private var nsPopover

    @ViewBuilder
    private var customPopover: some View {
        if let popoverTarget {
            Text("Popover for \(popoverTarget)")
                .padding()
                .foregroundStyle(.gray)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(white: 0.95))
                        .shadow(radius: 6)
                }
                .padding()
                .matchedGeometryEffect(
                    id: popoverTarget,
                    in: nsPopover,
                    properties: .position,
                    anchor: popoverTarget.anchorForPopover,
                    isSource: false
                )
        }
    }

    private func showPopover(target: PopoverTarget) {
        if popoverTarget != nil {
            withAnimation {
                popoverTarget = nil
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // 애니메이션 시간 고려
                popoverTarget = target
            }
        } else {
            popoverTarget = target
        }
    }

    var body: some View {
        ZStack {
            VStack {
                Text("Text 1")
                    .padding()
                    .background(.blue)
                    .onTapGesture { showPopover(target: .text1) }
                    .matchedGeometryEffect(id: PopoverTarget.text1, in: nsPopover, anchor: .bottom)
                    .padding(.top, 50)
                    .padding(.leading, 100)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Text 2")
                    .padding()
                    .background(.orange)
                    .onTapGesture { showPopover(target: .text2) }
                    .matchedGeometryEffect(id: PopoverTarget.text2, in: nsPopover, anchor: .topLeading)
                    .padding(.top, 100)
                    .padding(.trailing, 40)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Spacer()

                Text("Text 3")
                    .padding()
                    .background(.green)
                    .onTapGesture { showPopover(target: .text3) }
                    .matchedGeometryEffect(id: PopoverTarget.text3, in: nsPopover, anchor: .top)
                    .padding(.bottom, 250)
            }
            customPopover
                .transition(
                    .opacity.combined(with: .scale)
                    .animation(.bouncy(duration: 0.25, extraBounce: 0.2))
                )
        }
        .foregroundStyle(.white)
        .contentShape(Rectangle())
        .onTapGesture {
            popoverTarget = nil
        }
    }
}

#Preview {
    ColorPicker(color: .constant(0))
}
