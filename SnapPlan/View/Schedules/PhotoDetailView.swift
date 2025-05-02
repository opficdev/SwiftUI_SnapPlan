//
//  PhotoDetailView.swift
//  SnapPlan
//
//  Created by opfic on 5/2/25.
//

import SwiftUI
import UIKit

struct PhotoDetailView: View {
    @State private var image: UIImage
    
    init(image: UIImage) {
        self._image = State(initialValue: image)
    }
    
    var body: some View {
        ZoomableScrollView() {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
        .padding(.vertical)
    }
}
