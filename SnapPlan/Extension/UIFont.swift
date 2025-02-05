//
//  UIFont.swift
//  SnapPlan
//
//  Created by opfic on 2/5/25.
//

import SwiftUI

extension UIFont {
    static func from(font: Font) -> UIFont.TextStyle {
        switch font {
        case .largeTitle:
            return .largeTitle
        case .title:
            return .title1
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .body:
            return .body
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption:
            return .caption1
        case .caption2:
            return .caption2
        default:
            return .body
        }
    }
}
