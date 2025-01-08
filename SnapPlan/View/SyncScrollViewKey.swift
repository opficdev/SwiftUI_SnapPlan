//
//  SyncScrollKey.swift
//  SnapPlan
//
//  Created by opfic on 1/8/25.
//

import Foundation
import SwiftUI

struct SyncScrollViewKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

