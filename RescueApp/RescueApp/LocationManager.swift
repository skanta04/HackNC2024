import CoreLocation
import MapKit
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var hasLocationAccess: Bool = false

    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocationAccess() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            checkLocationAuthorization()
        }
    }
    
    func checkLocationAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            hasLocationAccess = false
        case .restricted, .denied:
            hasLocationAccess = false
        case .authorizedAlways, .authorizedWhenInUse:
            hasLocationAccess = true
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          guard let location = locations.last else { return }
          userLocation = location
      }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
    }
}
