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
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    private var region: Binding<MKCoordinateRegion> {
        Binding {
            mapVM.region
        } set: { region in
            DispatchQueue.main.async {
                mapVM.region = region
            }
        }
    }
    
    var body: some View {
        Map(coordinateRegion: region, showsUserLocation: true, annotationItems: mapVM.annotations) { point in
            MapMarker(coordinate: point.annotation.coordinate, tint: Color.blue)
        }
        .onAppear {
            mapVM.showLocation(location: scheduleVM.location, address: scheduleVM.address)
        }
        .onChange(of: mapVM.userLocation) { location in
            DispatchQueue.main.async {
                if let location = location, scheduleVM.address.isEmpty {
                    mapVM.region.center = location
                }
            }
        }
        .ignoresSafeArea(.all, edges: [.bottom, .horizontal])
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text(scheduleVM.location)
                    .bold()
            }
        }
    }
}
