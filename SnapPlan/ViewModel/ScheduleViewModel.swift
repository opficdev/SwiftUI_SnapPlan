//
//  ScheduleViewModel.swift
//  SnapPlan
//
//  Created by opfic on 1/31/25.
//

import SwiftUI
import Combine

final class ScheduleViewModel: ObservableObject {
    @Published var keyboardHeight = CGFloat.zero
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = Self.keyboardHeightPublisher
            .sink { height in
                self.keyboardHeight = height
            }
    }
    
    static var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
                .map { $0.height },
            
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        )
        .eraseToAnyPublisher()
    }
}
