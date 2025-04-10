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

extension View {
    func pagingEnabled() -> some View {
        modifier(PagingScrollViewModifier())
    }
}
