//
//  PermissionViewModel.swift
//  SnapPlan
//
//  Created by opfic on 4/20/25.
//

import SwiftUI
import AVFoundation
import Network

final class PermissionViewModel: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    @Published var ccellularPermission: Bool = false
    @Published var locationPermission: Bool = false
    @Published var micPermission: Bool = false
    
    @Published var showPermissionAlert: Bool = false
    @Published var permissionTitle = ""
    @Published var permissionMsg = ""
        
    func checkCellularPermission() {
        
    }
    
    func checkMicPermission() -> Bool {
        let permission = AVAudioSession.sharedInstance().recordPermission
        
        if permission == .granted {
            return true
        }
        self.permissionTitle = "마이크 권한 필요"
        self.permissionMsg = "음성 메모를 녹음하기 위해서는 권한이 필요해요.\n설정에서 권한을 허용해 주세요."
        self.showPermissionAlert = true
        return false
    }
    
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
