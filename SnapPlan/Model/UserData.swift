//
//  UserData.swift
//  SnapPlan
//
//  Created by opfic on 3/18/25.
//

import Foundation
import UIKit

struct UserData: Codable {
    let uid: UUID
    let displayName: String
    let email: String
    let is12TimeFmt: Bool
    let name: String
    let screenMode: UIUserInterfaceStyle
    let signedAt: Date
}
