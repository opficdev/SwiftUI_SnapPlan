//
//  View.swift
//  SnapPlan
//
//  Created by opfic on 4/10/25.
//

import SwiftUI
import SwiftUIIntrospect

struct PagingScrollViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .scrollTargetBehavior(.paging)
        }
        else {
            content
                .introspect(.scrollView, on: .iOS(.v16)) { scrollView in
                    scrollView.isPagingEnabled = true
                }
        }
    }
}

struct ShadowRemover: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 초기 제거
        removeAllShadows(uiView)
        
        // 타이머를 사용하여 주기적으로 그림자 제거
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.removeAllShadows(uiView)
        }
        
        // 이전 타이머 제거
        if let existingTimer = context.coordinator.timer {
            existingTimer.invalidate()
        }
        context.coordinator.timer = timer
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var timer: Timer?
        
        deinit {
            timer?.invalidate()
        }
    }
    
    private func removeAllShadows(_ uiView: UIView) {
        DispatchQueue.main.async {
            if let parentView = uiView.superview?.superview {
                self.applyNoShadow(to: parentView)
            }
        }
    }
    
    private func applyNoShadow(to view: UIView) {
        view.layer.shadowOpacity = 0
        view.layer.shadowRadius = 0
        view.layer.shadowOffset = .zero
        view.clipsToBounds = true
        
        for subview in view.subviews {
            applyNoShadow(to: subview)
        }
    }
}

extension View {
    func pagingEnabled() -> some View {
        modifier(PagingScrollViewModifier())
    }
    
    func removeShadow() -> some View {
        self.background(ShadowRemover())
    }
}
