//
//  MapView.swift
//  RescueApp
//
//  Created by Alexandra Marum on 11/2/24.
//

import MapKit
import SwiftUI
import SwiftData

struct MapView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Environment(\.modelContext) var context
    @Query(sort: \Message.timestamp, order: .reverse) var messages: [Message]

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: messages,
            annotationContent: { message in
            MapMarker(coordinate: CLLocationCoordinate2D(latitude: message.latitude, longitude: message.longitude))
        })
            .onAppear {
                if let userLocation = locationManager.userLocation {
                    region.center = userLocation.coordinate
                }
            }
            .onChange(of: locationManager.userLocation) { newLocation in
                if let newLocation = newLocation {
                    region.center = newLocation.coordinate
                }
            }
    }
}

#Preview {
    MapView(locationManager: LocationManager())
}
