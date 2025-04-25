//
//  NetworkViewModel.swift
//  SnapPlan
//
//  Created by opfic on 4/20/25.
//

import Network
import SwiftUI

final class NetworkViewModel: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = false
    @Published var showNetworkAlert = false
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                
                if !path.usesInterfaceType(.wifi) && !path.usesInterfaceType(.cellular) && path.status != .satisfied {
                    self?.showNetworkAlert = true
                }
            }
        }
        monitor.start(queue: queue)
    }
}
