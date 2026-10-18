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
    private var completion: ((Result<String, Error>) -> Void)?
    private var geocodingRequest: MKReverseGeocodingRequest?
    private var timeoutTask: Task<Void, Never>?
    private var hasRequestedLocation: Bool = false

    isolated deinit {

        self.timeoutTask?.cancel()
        self.geocodingRequest?.cancel()
        self.manager.stopUpdatingLocation()

    }

    func findCity(completion: @escaping (Result<String, Error>) -> Void) {

        cancel()
        self.completion = completion
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyKilometer
        handleAuthorization()

    }

    func cancel() {

        self.completion = nil
        self.timeoutTask?.cancel()
        self.timeoutTask = nil
        self.geocodingRequest?.cancel()
        self.geocodingRequest = nil
        self.manager.stopUpdatingLocation()
        self.manager.delegate = nil
        self.hasRequestedLocation = false

    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard self.completion != nil, self.geocodingRequest == nil else { return }
        guard let location = locations.last,
              let request = MKReverseGeocodingRequest(location: location) else {

            finish(.failure(CLError(.locationUnknown)))
            return

        }

        self.manager.stopUpdatingLocation()
        self.geocodingRequest = request
        request.preferredLocale = .current

        request.getMapItems { [weak self] mapItems, error in

            guard let self, self.completion != nil else { return }

            if let city = mapItems?.first?.addressRepresentations?.cityName,
               !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                self.finish(.success(city))

            } else {
                self.finish(.failure(error ?? CLError(.geocodeFoundNoResult)))
            }

        }

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finish(.failure(error))
    }

    private func handleAuthorization() {

        guard self.completion != nil else { return }

        switch self.manager.authorizationStatus {
        case .notDetermined:
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

    private func finish(_ result: Result<String, Error>) {

        let completion = self.completion
        cancel()
        completion?(result)

    }

}
