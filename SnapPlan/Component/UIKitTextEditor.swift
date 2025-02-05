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
        textView.isScrollEnabled = false
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

        DispatchQueue.main.async {
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

            DispatchQueue.main.async {
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
