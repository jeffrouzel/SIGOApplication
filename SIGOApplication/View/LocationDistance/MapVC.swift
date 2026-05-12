//
//  MapVC.swift
//  SIGOApplication
//
//  Created by training2 on 5/10/26.
//
import UIKit
import MapKit
import CoreLocation

final class MapVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var detailCardView: UIView!
    @IBOutlet var detailViews: [UIView]!
    
    @IBOutlet weak var lbl_desName: UILabel!
    @IBOutlet weak var lbl_desAddress: UILabel!
    @IBOutlet weak var lbl_traveltime: UILabel!
    @IBOutlet weak var lbl_distance: UILabel!

    // MARK: - Properties
    private let viewModel = MapDistanceViewModel()
    private var destinationAnnotation: MKPointAnnotation?
    private var lastRouteInfo: RouteInfo?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        showUI()
        assignDelegates()
        bindViewModel()
        viewModel.requestLocationPermission()
        detailCardView.isHidden = true
        print("VC loaded")
    }

    // MARK: - Setup
    private func assignDelegates() {
        viewModel.locationManager.delegate = self
        viewModel.searchCompleter.delegate = self
        mapView.delegate = self
        locationSearchBar.delegate = self
    }
    // MARK: - Data Binding

    private func bindViewModel() {
        viewModel.onRouteReady = { [weak self] route, info in
            DispatchQueue.main.async {
                self?.lastRouteInfo = info
                self?.displayRoute(route, info: info)
            }
        }

        viewModel.onError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showError(message)
            }
        }
    }
    // MARK: - UI
    private func updateDetailsCard(with info: RouteInfo) {
        lbl_desName.text = info.destinationName
        lbl_desAddress.text = info.destinationAddress.isEmpty
            ? "Location found"
            : info.destinationAddress
        lbl_traveltime.text = viewModel.travelTimeText
        lbl_distance.text = viewModel.distanceText
        detailCardView.isHidden = false
    }
    private func showUI(){
        view.setGradientBackground(isDay: true)
        locationSearchBar.styleRounded()
        detailCardView.styleAsCard()
        detailViews.forEach {$0.styleAsCardOrange()}
        
        mapView.layer.cornerRadius = 24
        mapView.clipsToBounds = true
        mapView.layer.borderWidth = 3
        mapView.layer.borderColor = UIColor.black.cgColor
    }
    // MARK: - Map
    private func displayRoute(_ route: MKRoute?, info: RouteInfo) {
        // Remove previous state
        mapView.removeOverlays(mapView.overlays)
        if let existing = destinationAnnotation {
            mapView.removeAnnotation(existing)
            destinationAnnotation = nil
        }

        // Add destination pin
        if let mapItem = viewModel.routeDestination {
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapItem.location.coordinate
            annotation.title = mapItem.name
            mapView.addAnnotation(annotation)
            destinationAnnotation = annotation
        }

        // Draw route polyline
        if let route {
            mapView.addOverlay(route.polyline, level: .aboveRoads)
            let padding = UIEdgeInsets(top: 60, left: 24, bottom: 260, right: 24)
            mapView.setVisibleMapRect(route.polyline.boundingMapRect,
                                      edgePadding: padding,
                                      animated: true)
        }

        updateDetailsCard(with: info)
    }

    private func clearMapRouteUI() {
        mapView.removeOverlays(mapView.overlays)
        if let annotation = destinationAnnotation {
            mapView.removeAnnotation(annotation)
            destinationAnnotation = nil
        }
        detailCardView.isHidden = true

        if let userCoord = viewModel.userCoordinate {
            let region = MKCoordinateRegion(center: userCoord,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
// MARK: - CLLocationManagerDelegate
extension MapVC: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            showError("Location access denied. Please enable it in Settings.")
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        viewModel.handleLocationUpdate(location)

        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: 1000,
                                        longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError("Location error: \(error.localizedDescription)")
    }
}
// MARK: - MKLocalSearchCompleterDelegate
extension MapVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print("Completer results: \(completer.results.count)")
        guard let completion = completer.results.first else { return }
        MKLocalSearch(request: MKLocalSearch.Request(completion: completion))
            .start { [weak self] response, error in
                guard let self else { return }

                if let error {
                    self.showError("Search failed: \(error.localizedDescription)")
                    return
                }

                guard let mapItem = response?.mapItems.first else { return }

                DispatchQueue.main.async {
                    self.viewModel.selectMapItem(mapItem)
                }
            }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // Non-critical — silently ignore
    }
}
// MARK: - UISearchBarDelegate
extension MapVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.updateSearchQuery(searchText)
        if searchText.isEmpty {
            clearMapRouteUI()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        viewModel.clearRoute()
        clearMapRouteUI()
    }
}
// MARK: - MKMapViewDelegate

extension MapVC: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor(red: 1.0, green: 0.60, blue: 0.0, alpha: 1.0)
        renderer.lineWidth = 6
        renderer.lineCap = .round
        renderer.lineJoin = .round
        return renderer
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let id = "DestinationPin"
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
                   ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
        view.annotation = annotation
        view.markerTintColor = UIColor(red: 1.0, green: 0.60, blue: 0.0, alpha: 1.0)
        view.canShowCallout = true
        return view
    }
}
