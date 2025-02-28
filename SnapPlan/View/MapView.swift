//
//  MapView.swift
//  SnapPlan
//
//  Created by opfic on 2/17/25.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var mapVM = MapViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Binding var location: String
    
    var body: some View {
        Map(coordinateRegion: region, showsUserLocation: true)
            .onChange(of: mapVM.userLocation) { location in
                DispatchQueue.main.async {
                    if let location = location {
                        region.center = location
                    }
                }
            }
        .ignoresSafeArea(.all, edges: [.bottom, .horizontal])
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("위치")
                    .bold()
            }
        }
        .navigationTitle("")
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

#Preview {
    MapView(location: .constant(""))
}
