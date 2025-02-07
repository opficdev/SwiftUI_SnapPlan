//
//  UIUserInterfaceStyle.swift
//  SnapPlan
//
//  Created by opfic on 2/7/25.
//

import SwiftUI

extension UIUserInterfaceStyle {
    var rawValue: String {
        switch self {
        case .unspecified: return "unspecified"
        case .light: return "light"
        case .dark: return "dark"
        @unknown default: return "unspecified"
        }
    }
    
    init(rawValue: String) {
        switch rawValue {
        case "light": self = .light
        case "dark": self = .dark
        default: self = .unspecified
        }
    }
}
