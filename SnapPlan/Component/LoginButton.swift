//
//  LoginButton.swift
//  SnapPlan
//
//  Created by opfic on 4/25/25.
//

import SwiftUI

struct LoginButton: View {
    @State private var logo: UIImage?
    @State private var text = ""
    @State private var height = CGFloat.zero
    let action: () -> Void
    
    
    init(logo: UIImage? = nil, text: String = "", action: @escaping () -> Void = {}) {
        self._logo = State(initialValue: logo)
        self._text = State(initialValue: text)
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack {
                Text(text)
                    .foregroundStyle(Color.primary)
                    .font(.system(size: height / 2))
            }
            .overlay {
                if let logo = logo {
                    Image(uiImage: logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: height / 2, height: height / 2)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            GeometryReader { proxy in
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 1)
                    .onAppear {
                        height = proxy.size.height
                    }
            }
        )
        
    }
}

#Preview {
    LoginButton()
}
