//
//  MapViewModel.swift
//  SnapPlan
//
//  Created by opfic on 2/17/25.
//

import Foundation
import CoreLocation
import MapKit

@MainActor
final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    @Published var region: MKCoordinateRegion
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var location: String = ""
    @Published var annotations = [PointAnnotation]()
    
    override init() {
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization() // 위치 권한 요청
        self.locationManager.startUpdatingLocation() // 위치 업데이트 시작
    }
    
    // MARK: nonisolated - 메서드나 프로퍼티가 특정 actor에 의해 격리되지 않음을 나타내는 키워드
    // 위치 업데이트가 있을 때마다 호출되는 메소드
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            guard let newLocation = locations.last else { return }
            self.userLocation = newLocation.coordinate // 최신 위치 저장
        }
    }
    
    // 위치 업데이트 실패 시 호출되는 메소드
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
    
    // String 형태의 장소 주소를 매개변수로 받아서 지도에 해당 주소를 표시하는 메소드
    nonisolated func showLocation(location: String, address: String = "") {
        if address.isEmpty {
            DispatchQueue.main.async {
                if let userLocation = self.userLocation {
                    self.region = MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
                self.annotations.removeAll()
            }
            return
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = address
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, let mapItem = response.mapItems.first else { return }
            
            DispatchQueue.main.async {
                // 새로운 annotation 생성
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = location
                annotation.subtitle = address
                
                
                // 지도 업데이트
                self.region = MKCoordinateRegion(
                    center: mapItem.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                
                // annotation 업데이트
                self.annotations = [PointAnnotation(annotation: annotation)]
            }
        }
    }
}
