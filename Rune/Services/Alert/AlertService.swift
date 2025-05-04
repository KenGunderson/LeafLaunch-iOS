//
//  AlertService.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/5/24.
//

import SwiftUI
import Combine

// TODOs:
/// Clean `Preview` to use what we normally use
/// Refactor to use AlertService in `Login / Signup` Views

class AlertService: AlertServiceProtocol, ObservableObject {
    
    @Published var alerts: [Alert] = []
    var alertsPublisher: AnyPublisher<[Alert], Never> {
        return self.$alerts.eraseToAnyPublisher()
    }
    
    @Published var requestedToDeleteAlert = false
    var requestedToDeleteAlertPublisher: AnyPublisher<Bool, Never> {
        return self.$requestedToDeleteAlert.eraseToAnyPublisher()
    }
    
    private let logger = RuneLogger.service(.alert)
    
    init() {
        
        self.logger
            .logInit()
        
    }
    
    deinit {
        
        self.logger
            .logDeinit()
        
    }
    
    func showAlert(_ alert: Alert) {
        
        alerts.append(alert)
        
        self.logger
            .debugMessage("Adding New Alert: \(alert.id)\nNew Alert Count: \(self.alerts.count)")
        
    }
    
    func dismissAlert(_ alert: Alert) {
        
        alerts.removeAll { alert.id == $0.id }
        
        self.logger
            .prettyDebugMessage("Removing Alert: \(alert.id)\nNew Alert Count: \(self.alerts.count)")
        
    }
    
    func dismiss(_ animated: Bool = true) {
        
        if animated {
            self.requestedToDeleteAlert = true
        }
        else {
            self.alerts.removeLast()
        }
        
    }
    
    func dismissLoadingIndicator() {
        
        if let loadingAlert = self.alerts.first(where: { $0.alert == .simpleLoadingIndicator }) {
            alerts.removeAll { loadingAlert.id == $0.id }
        }
        
        self.logger
            .prettyDebugMessage("Removing Loading Indicator\nNew Alert Count: \(self.alerts.count)")
        
    }
    
    func dismissImmediately() {
        
        self.alerts.removeLast()
        
        self.logger
            .prettyDebugMessage("Removing Alert\nNew Alert Count: \(self.alerts.count)")
        
    }
    
    func dismissAll() {
        
        self.alerts.removeAll()
        
        self.logger
            .prettyDebugMessage("Removing Alert\nNew Alert Count: \(self.alerts.count)")
        
    }
    
    func setRequestToDeleteAlert(_ shouldRequest: Bool) {
        self.requestedToDeleteAlert = shouldRequest
    }
    
}
