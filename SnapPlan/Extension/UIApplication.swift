//
//  UIApplication.swift
//  SnapPlan
//
//  Created by opfic on 5/2/25.
//

import UIKit

extension UIApplication {
    static var safeAreaInsets: UIEdgeInsets {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets ?? .zero
    }
}
