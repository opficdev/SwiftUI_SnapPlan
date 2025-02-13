//
//  UIViewModel.swift
//  SnapPlan
//
//  Created by opfic on 2/11/25.
//

import SwiftUI

class UIViewModel: ObservableObject {
    @Published var bottomPadding: CGFloat = UIScreen.main.bounds.height * 0.1
}
