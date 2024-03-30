import Foundation
import GoogleMaps
import GooglePlaces
import GoogleMapsUtils
import SDWebImage

protocol GoogleMapsServiceDelegate: AnyObject {
    func googleMaps(didSelectAnnotation uuid: UUID)
    func googleMaps(didSelectAnnotationAt index: Int)
    func googleMaps(didUpdateAddress address: String?, city: String?, street: String?)
    func googleMaps(didUpdateAddressAt latitude: CGFloat, longitude: CGFloat)
}

extension GoogleMapsServiceDelegate {
    func googleMaps(didSelectAnnotation uuid: UUID) {}
    func googleMaps(didSelectAnnotationAt index: Int) {}
    func googleMaps(didUpdateAddress address: String?, city: String?, street: String?) {}
    func googleMaps(didUpdateAddressAt latitude: CGFloat, longitude: CGFloat) {}
}

class GoogleMapsService: NSObject {
    weak var delegate: GoogleMapsServiceDelegate?
    private lazy var geoCoder = GMSGeocoder()
    private var clusterManager: GMUClusterManager?
    private weak var googleMapView: GMSMapView? {
        didSet {
            self.googleMapView?.delegate = self
            returnToMyLocationButtonEnable = true
            myCurrentLocationAnnotationEnable = true
        }
    }
    
    var returnToMyLocationButtonEnable: Bool {
        set { googleMapView?.settings.myLocationButton = newValue }
        get { googleMapView?.settings.myLocationButton ?? false }
    }
    
    var myCurrentLocationAnnotationEnable: Bool {
        set { googleMapView?.isMyLocationEnabled = newValue }
        get { googleMapView?.isMyLocationEnabled ?? false }
    }
    
    private var markers: [GMSMarker: UUID] = [:]
    private var markersIndices: [GMSMarker: Int] = [:]
    private(set) var zoom: Float
    
    init(zoom: Float = 15) {
        self.zoom = zoom
        super.init()
    }
    
    deinit {
        print("-- Deinit GoogleMapsService")
    }
    
    /// Setup Configurations of Google Maps Services
    static func setupConfigurations() {
        let apiKey = ""
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)
    }
    
    func setGoogleMapView(_ view: GMSMapView) {
        self.googleMapView = view
        configureCluster(view)
    }
    
    func configureCluster(_ view: GMSMapView) {
        // Set ClusterManager
        let iconGenerator = CustomClusterIconGenerator()
        let renderer = GMUDefaultClusterRenderer(mapView: view, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(
            map: view,
            algorithm: GMUNonHierarchicalDistanceBasedAlgorithm(),
            renderer: renderer
        )
        clusterManager?.setDelegate(self, mapDelegate: self)
    }
    
    /// Add Annotation to GoogleMapView
    /// - Parameters:
    ///   - title: Annotation Title
    ///   - icon: Annotation Icon
    ///   - snippet: Snippet text, shown beneath the title in the info window when selected.
    ///   - lat: Latitude
    ///   - long: Longitude
    /// - Returns: UUID that identify Annotation that was added to GoogleMapView
    func addAnnotation(lat: Double, long: Double, title: String?, icon: UIImage?, snippet: String?) -> UUID {
        let marker = createMarker(
            position: CLLocationCoordinate2D(latitude: lat, longitude: long),
            title: title,
            icon: icon,
            snippet: snippet
        )
        let uuid = UUID()
        self.markers[marker] = uuid
        return uuid
    }
    
    /// Add Annotation to GoogleMapView
    /// - Parameters:
    ///   - index: Index that identify Annotation
    ///   - title: Annotation Title
    ///   - icon: Annotation Icon
    ///   - snippet: Snippet text, shown beneath the title in the info window when selected.
    ///   - lat: Latitude
    ///   - long: Longitude
    func addAnnotation(index: Int, lat: Double, long: Double, title: String?, icon: UIImage?, snippet: String?) {
        let marker = createMarker(
            position: CLLocationCoordinate2D(latitude: lat, longitude: long),
            title: title,
            icon: icon,
            snippet: snippet
        )
        self.markersIndices[marker] = index
    }
    
    private func createMarker(position: CLLocationCoordinate2D, title: String?, icon: UIImage?, snippet: String?) -> GMSMarker {
        // Create a marker in the center of the map.
        let marker = GMSMarker(position: position)
        marker.icon = icon // Annotation Icon
        marker.title = title
        marker.snippet = snippet
        // marker.map = googleMapView
        clusterManager?.add(marker) // Will add Marker to the MapView
        clusterManager?.cluster()
        return marker
    }
    
    /// Make the given location in the center of GoogleMapView
    /// - Parameters:
    ///   - lat: Latitude
    ///   - long: Longitude
    func focus(lat: Double, long: Double) {
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: zoom)
        googleMapView?.animate(to: camera)
    }
}

// MARK: - GMSMapView Delegate
extension GoogleMapsService: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let uuidForSelectedMarker = markers[marker] {
            delegate?.googleMaps(didSelectAnnotation: uuidForSelectedMarker)
        }
        if let indexForSelectedMarker = markersIndices[marker] {
            delegate?.googleMaps(didSelectAnnotationAt: indexForSelectedMarker)
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        // Map View will Move
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        delegate?.googleMaps(didUpdateAddressAt: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
        // This called after user has moved the map view and finish moving
        geoCoder.reverseGeocodeCoordinate(position.target) { [weak self] response, error in
            guard let self = self else { return }
            if let error = error {
                print("-- Error:", error)
                return
            }
            
            if let address = response?.firstResult() {
                self.delegate?.googleMaps(didUpdateAddress: address.lines?.first, city: address.locality, street: address.thoroughfare)
            }
        }
    }
}


// MARK: - ClusterManager Delegate
extension GoogleMapsService: GMUClusterManagerDelegate {
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        if let mapView = googleMapView {
            // zoom-in on tapped cluster
            let camera = GMSCameraPosition.camera(
                withLatitude: cluster.position.latitude,
                longitude: cluster.position.longitude,
                zoom: mapView.camera.zoom + 1.5
            )
            mapView.animate(to: camera)
        }
        return true
    }
}


// MARK: - Cluster
class CustomClusterIconGenerator: GMUDefaultClusterIconGenerator {

    override func icon(forSize size: UInt) -> UIImage {
        guard
            let redCircleImage = UIImage(named: "redCircle")?.sd_resizedImage(
                with: CGSize(width: 40, height: 40),
                scaleMode: SDImageScaleMode.aspectFit
            )
        else { return UIImage() }
        
        let image = textToImage(
            drawText: "\(size / 3)",
            inImage: redCircleImage,
            font: UIFont.systemFont(ofSize: 15)
        )
        return image
    }

    private func textToImage(drawText text: String, inImage image: UIImage, font: UIFont) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        image.draw(in: CGRect(x: 0,
                              y: 0,
                              width: image.size.width,
                              height: image.size.height))
        
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = NSTextAlignment.center
        
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.paragraphStyle: textStyle,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        // vertically center (depending on font)
        let textH = font.lineHeight
        let textY = (image.size.height-textH)/2
        let textRect = CGRect(x: 0, y: textY, width: image.size.width, height: textH)
        text.draw(in: textRect.integral, withAttributes: attributes)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}
