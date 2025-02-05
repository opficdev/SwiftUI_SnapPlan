//
//  UIFont.swift
//  SnapPlan
//
//  Created by opfic on 2/5/25.
//

import SwiftUI

extension UIFont {
    static func from(font: Font) -> UIFont {
        switch font {
        case .largeTitle: return UIFont.preferredFont(forTextStyle: .largeTitle)
        case .title: return UIFont.preferredFont(forTextStyle: .title1)
        case .title2: return UIFont.preferredFont(forTextStyle: .title2)
        case .title3: return UIFont.preferredFont(forTextStyle: .title3)
        case .headline: return UIFont.preferredFont(forTextStyle: .headline)
        case .body: return UIFont.preferredFont(forTextStyle: .body)
        case .callout: return UIFont.preferredFont(forTextStyle: .callout)
        case .subheadline: return UIFont.preferredFont(forTextStyle: .subheadline)
        case .footnote: return UIFont.preferredFont(forTextStyle: .footnote)
        case .caption: return UIFont.preferredFont(forTextStyle: .caption1)
        case .caption2: return UIFont.preferredFont(forTextStyle: .caption2)
        default: return UIFont.systemFont(ofSize: UIFont.systemFontSize)
        }
    }
}
