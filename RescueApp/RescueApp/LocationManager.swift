//
//  LocationManager.swift
//  RescueApp
//
//  Created by Alexandra Marum on 11/2/24.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var hasLocationAccess: Bool = false
    
    override init() {
           super.init()
           manager.delegate = self
           manager.desiredAccuracy = kCLLocationAccuracyBest
       }
    
    func requestLocationAccess() {
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            hasLocationAccess = false
        case .restricted:
            hasLocationAccess = false
        case .denied:
            hasLocationAccess = false
        case .authorizedAlways:
            hasLocationAccess = true
        case .authorizedWhenInUse:
            hasLocationAccess = true
        case .authorized:
            hasLocationAccess = true
        @unknown default:
            hasLocationAccess = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
