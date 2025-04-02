//
//  ImageAsset.swift
//  SnapPlan
//
//  Created by opfic on 3/29/25.
//

import SwiftUI

struct ImageAsset: Identifiable, Equatable {
    let id: String
    let image: UIImage
    
    init(id: String, image: UIImage) {
        let tmp = id.replacingOccurrences(of: "/", with: "_")
        self.id = String(tmp[..<(tmp.firstIndex(of: ".") ?? tmp.endIndex)])
        self.image = image
    }
}
