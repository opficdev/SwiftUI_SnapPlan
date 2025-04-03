//
//  UIUserInterfaceStyle.swift
//  SnapPlan
//
//  Created by opfic on 2/7/25.
//

import SwiftUI

extension UIUserInterfaceStyle: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "light": self = .light
        case "dark": self = .dark
        case "unspecified": self = .unspecified
        default: self = .unspecified
        }
    }
    
    public init(stringValue: String) {
        switch stringValue.lowercased() {
        case "light": self = .light
        case "dark": self = .dark
        case "unspecified": self = .unspecified
        default: self = .unspecified
        }
    }
    
    var rawValue: String {
        switch self {
        case .unspecified: return "unspecified"
        case .light: return "light"
        case .dark: return "dark"
        @unknown default: return "unspecified"
        }
    }
}
