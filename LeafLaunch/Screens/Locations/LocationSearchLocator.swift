//
//  LocationSearchLocator.swift
//  LeafLaunch
//
//  Created by KC Gunderson on 10/17/26.
//

import CoreLocation
import MapKit

@MainActor
final class LocationSearchLocator: NSObject, @preconcurrency CLLocationManagerDelegate {

    private let manager = CLLocationManager()
    private var completion: ((Result<LocationSearchResult, Error>) -> Void)?
    private var geocodingRequest: MKGeocodingRequest?
    private var reverseGeocodingRequest: MKReverseGeocodingRequest?
    private var timeoutTask: Task<Void, Never>?
    private var hasRequestedLocation: Bool = false
    private var canRequestAuthorization: Bool = false

    var isAuthorized: Bool {

        switch self.manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse: return true
        default: return false
        }

    }

    isolated deinit {

        self.timeoutTask?.cancel()
        self.geocodingRequest?.cancel()
        self.reverseGeocodingRequest?.cancel()
        self.manager.stopUpdatingLocation()

    }

    func findLocation(requestAuthorization: Bool = true,
                      completion: @escaping (Result<LocationSearchResult, Error>) -> Void) {

        cancel()
        self.completion = completion
        self.canRequestAuthorization = requestAuthorization
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyKilometer
        handleAuthorization()

    }

    func geocode(address: String) async throws -> CLLocation {

        try Task.checkCancellation()

        let result: LocationSearchResult = try await withTaskCancellationHandler {

            try await withCheckedThrowingContinuation { continuation in

                startGeocoding(address: address) { result in
                    continuation.resume(with: result)
                }

            }

        } onCancel: { [weak self] in

            Task { @MainActor [weak self] in self?.cancel() }

        }

        return result.location

    }

    func cancel() {
        finish(.failure(CancellationError()))
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard self.completion != nil,
              self.hasRequestedLocation,
              self.reverseGeocodingRequest == nil else { return }
        guard let location = locations.last, location.horizontalAccuracy >= 0 else {

            finish(.failure(CLError(.locationUnknown)))
            return

        }

        self.manager.stopUpdatingLocation()
        self.manager.delegate = nil
        reverseGeocode(location: location)

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(.failure(error))
    }

    private func startGeocoding(address: String,
                                completion: @escaping (Result<LocationSearchResult, Error>) -> Void) {

        cancel()
        self.completion = completion

        guard let request = MKGeocodingRequest(addressString: address) else {

            finish(.failure(CLError(.geocodeFoundNoResult)))
            return

        }

        self.geocodingRequest = request
        request.preferredLocale = .current
        startTimeout()

        request.getMapItems { [weak self, weak request] mapItems, error in

            guard let self, let request, self.geocodingRequest === request else { return }

            if let location = mapItems?.first?.location {
                self.finish(.success(LocationSearchResult(location: location, postalCode: nil)))
            } else {
                self.finish(.failure(error ?? CLError(.geocodeFoundNoResult)))
            }

        }

    }

    private func reverseGeocode(location: CLLocation) {

        guard let request = MKReverseGeocodingRequest(location: location) else {

            finish(.success(LocationSearchResult(location: location, postalCode: nil)))
            return

        }

        self.reverseGeocodingRequest = request
        request.preferredLocale = .current

        request.getMapItems { [weak self, weak request] mapItems, _ in

            guard let self, let request, self.reverseGeocodingRequest === request else { return }

            // MapKit's replacement address representations do not expose a structured postal code.
            let postalCode = mapItems?.first?.placemark.postalCode
            self.finish(.success(LocationSearchResult(location: location, postalCode: postalCode)))

        }

    }

    private func handleAuthorization() {

        guard self.completion != nil,
              self.geocodingRequest == nil,
              self.reverseGeocodingRequest == nil else { return }

        switch self.manager.authorizationStatus {
        case .notDetermined:

            guard self.canRequestAuthorization else {

                finish(.failure(CLError(.denied)))
                return

            }

            self.manager.requestWhenInUseAuthorization()

        case .authorizedAlways, .authorizedWhenInUse:

            guard !self.hasRequestedLocation else { return }
            self.hasRequestedLocation = true
            startTimeout()
            self.manager.requestLocation()

        case .denied, .restricted:
            finish(.failure(CLError(.denied)))
        @unknown default:
            finish(.failure(CLError(.locationUnknown)))
        }

    }

    private func startTimeout() {

        self.timeoutTask = Task { @MainActor [weak self] in

            do {

                try await Task.sleep(for: .seconds(20))
                try Task.checkCancellation()
                self?.finish(.failure(CLError(.locationUnknown)))

            } catch {}

        }

    }

    private func finish(_ result: Result<LocationSearchResult, Error>) {

        let completion = self.completion
        self.completion = nil
        self.timeoutTask?.cancel()
        self.timeoutTask = nil
        let geocodingRequest = self.geocodingRequest
        self.geocodingRequest = nil
        geocodingRequest?.cancel()
        let reverseGeocodingRequest = self.reverseGeocodingRequest
        self.reverseGeocodingRequest = nil
        reverseGeocodingRequest?.cancel()
        self.manager.stopUpdatingLocation()
        self.manager.delegate = nil
        self.hasRequestedLocation = false
        self.canRequestAuthorization = false
        completion?(result)

    }

}
