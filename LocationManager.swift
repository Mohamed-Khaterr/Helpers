import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    /// Ask delegate for changes in Authorization permission,
    /// - Parameter isAuthorized: User Authorization
    func locationManager(didChangeAuthorization isAuthorized: Bool)
    
    /// Ask delegate for changing in location
    /// - Parameter coordinate: Current Coordinate
    func locationManager(didUpdateLocation coordinate: CLLocationCoordinate2D?)
}

extension LocationManagerDelegate {
    func locationManager(didChangeAuthorization isAuthorized: Bool){}
    func locationManager(didUpdateLocation coordinate: CLLocationCoordinate2D?) {}
}

/*
    Now SPPermissions pod is not needed any more
 */

class LocationManager: NSObject {
    private let manager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    
    var isAuthorized: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
            
        case .notDetermined, .restricted, .denied:
            return false
            
        @unknown default: return false
        }
    }
    
    var currentLocationCoordinate: CLLocationCoordinate2D? {
        return manager.location?.coordinate
    }
            
    override init() {
        super.init()
        setupManager()
    }
    
    private func setupManager() {
        DispatchQueue.global(qos: .userInteractive).async {
            // Check if Location is Enabled in the System
            if CLLocationManager.locationServicesEnabled() {
                self.manager.delegate = self
                self.manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            }
        }
    }
    
    func askForAuthorization() {
        manager.requestWhenInUseAuthorization()
        
        // Ask for Authorization for use in foreground
        manager.requestAlwaysAuthorization()
    }
}


// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationManager(didUpdateLocation: locations.last?.coordinate)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.delegate?.locationManager(didChangeAuthorization: self.isAuthorized)
        }
    }
}

