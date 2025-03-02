//
//  PointAnnotation.swift
//  SnapPlan
//
//  Created by opfic on 3/2/25.
//

import Foundation
import MapKit

struct PointAnnotation: Identifiable {
    let id = UUID()
    let annotation: MKPointAnnotation
}
