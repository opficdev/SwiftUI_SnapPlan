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
    @Binding var minHeight: CGFloat
    private let placeholder: String
    
    init(text: Binding<String>, isFocused: Binding<Bool>, minHeight: Binding<CGFloat>, placeholder: String) {
        self._text = text
        self._isFocused = isFocused
        self._minHeight = minHeight
        self.placeholder = placeholder
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textContainer.lineFragmentPadding = 0
        textView.textColor = UIColor.label
        textView.autocorrectionType = .no
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
            self.minHeight = max(uiView.contentSize.height, minHeight)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updatePlaceholder(_ textView: UITextView) {
        if text.isEmpty && !isFocused {
            textView.text = placeholder
            textView.textColor = .gray
        }
        else if textView.textColor == .gray {
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
                self.parent.minHeight = min(textView.contentSize.height, self.parent.minHeight)
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
            parent.isFocused = false
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .gray
            }
        }
    }
}
