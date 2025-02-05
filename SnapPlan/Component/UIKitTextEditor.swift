//
//  UIKitTextEditor.swift
//  SnapPlan
//
//  Created by opfic on 2/4/25.
//

import SwiftUI
import UIKit

struct UIKitTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    private var minHeight: CGFloat
    private let font: Font
    private let placeholder: String
    
    init(text: Binding<String>, isFocused: Binding<Bool>, placeholder: String, font: Font = .body) {
        self._text = text
        self._isFocused = isFocused
        self.font = font
        self.minHeight = UIFont.from(font: font).lineHeight
        self.placeholder = placeholder
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.from(font: font)
        textView.textContainer.lineFragmentPadding = 0
        textView.textColor = UIColor.label
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false  // 스크롤 비활성화하여 높이 조정 가능하게 만듦
        updatePlaceholder(textView)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        updatePlaceholder(uiView)
        
        if isFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFocused && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }

        // ✅ SwiftUI에 알리지 않고 UIKit에서 크기를 조정
        DispatchQueue.main.async {
//            let newHeight = max(uiView.contentSize.height, self.minHeight)
//            if uiView.frame.size.height != newHeight {
//                uiView.frame.size.height = newHeight
//            }
            uiView.frame.size.height = uiView.contentSize.height
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updatePlaceholder(_ textView: UITextView) {
        if text.isEmpty && !isFocused {
            textView.text = placeholder
            textView.textColor = .gray
        } else if textView.textColor == .gray {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UIKitTextEditor
        
        init(_ parent: UIKitTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text

            // ✅ SwiftUI에 알리지 않고 UIKit에서 크기 변경
            DispatchQueue.main.async {
//                let newHeight = max(textView.contentSize.height, self.parent.minHeight)
//                if textView.frame.size.height != newHeight {
//                    textView.frame.size.height = newHeight
//                }
                textView.frame.size.height = textView.contentSize.height
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.isFocused = true
            if textView.textColor == .gray {
                textView.text = nil
                textView.textColor = .label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .gray
            }
        }
    }
}
