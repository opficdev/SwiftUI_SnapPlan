//
//  MapViewModel.swift
//  SnapPlan
//
//  Created by opfic on 2/17/25.
//

import Foundation
import CoreLocation

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    @Published var userLocation: CLLocationCoordinate2D?
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization() // 위치 권한 요청
        self.locationManager.startUpdatingLocation() // 위치 업데이트 시작
    }
    
    // 위치 업데이트가 있을 때마다 호출되는 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        self.userLocation = newLocation.coordinate // 최신 위치 저장
    }
    
    // 위치 업데이트 실패 시 호출되는 메서드
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
}
