//
//  MapViewModel.swift
//  SIGOApplication
//
//  Created by training2 on 5/10/26.
//
import Foundation
import MapKit
import CoreLocation

final class MapDistanceViewModel {

    // MARK: - Managers
    let locationManager = CLLocationManager()
    let searchCompleter = MKLocalSearchCompleter()

    // MARK: - Callbacks
    var onRouteReady: ((MKRoute?, RouteInfo) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - State
    private(set) var userLocation: CLLocation?
    private(set) var routeDestination: MKMapItem?
    private(set) var currentRoute: MKRoute?
    private(set) var currentRouteInfo: RouteInfo?
    
    var transportType: MKDirectionsTransportType = .automobile

    var userCoordinate: CLLocationCoordinate2D? {
        userLocation?.coordinate
    }

    // MARK: - Init

    init() {
        searchCompleter.resultTypes = [.address, .pointOfInterest]
    }

    // MARK: - Location

    func requestLocationPermission() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            onError?("Location access denied. Please enable it in Settings.")
        @unknown default:
            break
        }
    }

    func handleLocationUpdate(_ location: CLLocation) {
        userLocation = location
        locationManager.stopUpdatingLocation()

        searchCompleter.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 50_000,
            longitudinalMeters: 50_000
        )
        print("Location received: \(location.coordinate)")
    }

    // MARK: - Search

    func updateSearchQuery(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            return
        }
        searchCompleter.queryFragment = trimmed
    }

    func selectMapItem(_ mapItem: MKMapItem) {
        routeDestination = mapItem
        fetchRoute()
    }

    // MARK: - Route

    func fetchRoute() {
        print("Fetching route to: \(routeDestination?.name ?? "nil")")
        guard let userLocation, let routeDestination else {
            onError?("Unable to calculate route. Make sure location is enabled.")
            return
        }
        let destinationLocation = routeDestination.location
        let straightLine = userLocation.distance(from: destinationLocation)

        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = routeDestination
        request.transportType = transportType

        MKDirections(request: request).calculate { [weak self] response, error in
            guard let self else { return }

            let route = response?.routes.first
            self.currentRoute = route

            let info = RouteInfo(
                destinationName: routeDestination.name ?? "Unknown",
                destinationAddress: routeDestination.address?.shortAddress ?? "",
                straightLineMeters: straightLine,
                route: route
            )
            self.currentRouteInfo = info
            self.onRouteReady?(route, info)
        }
    }

    func clearRoute() {
        routeDestination = nil
        currentRoute = nil
        currentRouteInfo = nil
    }

    // MARK: - UI Related

    var travelTimeText: String {
        guard let interval = currentRoute?.expectedTravelTime else { return "N/A" }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: interval) ?? "N/A"
    }

    var distanceText: String {
        guard let info = currentRouteInfo else { return "--" }
        return info.straightLineMeters < 1000
            ? String(format: "%.0f m", info.straightLineMeters)
            : String(format: "%.1f km", info.straightLineMeters / 1000)
    }
}
