//
//  LocationManager.swift
//  SodiamTracker
//
//  Created by 伊藤総汰 on 2021/07/01.
//

import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var region = MKCoordinateRegion()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 1
        manager.allowsBackgroundLocationUpdates = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            let center = CLLocationCoordinate2D(
                latitude: $0.coordinate.latitude,
                longitude: $0.coordinate.longitude
            )
            region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 1000.0,
                longitudinalMeters: 1000.0
            )
        }
    }
    
    func toSpot() -> Spot {
        return Spot(latitude: self.region.center.latitude, longitude: self.region.center.longitude)
    }
    
    func toString() -> String {
        return String(self.region.center.latitude) + "," + String(self.region.center.longitude) + "\n"
    }
}
