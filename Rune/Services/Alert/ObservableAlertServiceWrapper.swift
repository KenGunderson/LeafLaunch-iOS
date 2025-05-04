//
//  ObservableAlertServiceWrapper.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 9/2/24.
//

import SwiftUI

@Observable
class ObservableAlertServiceWrapper: ObservableObject {
    
    private let alertService: AlertServiceProtocol
    private var cancelBag: CancelBag!
    
    var alerts: [Alert] = []
    var requestedToDeleteAlert = false
    
    init(alertService: AlertServiceProtocol) {
        
        self.alertService = alertService
        bindSubscribers()
        
    }
    
    func showAlert(_ alert: Alert) {
        alertService.showAlert(alert)
    }
    
    func dismissAlert(_ alert: Alert) {
        alertService.dismissAlert(alert)
    }
    
    func setRequestToDeleteAlert(_ shouldRequest: Bool) {
        self.requestedToDeleteAlert = shouldRequest
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.alertService
            .alertsPublisher
            .receiveOnMain()
            .sink { alerts in
                self.alerts = alerts
            }
            .store(in: &self.cancelBag)
        
        self.alertService
            .requestedToDeleteAlertPublisher
            .receiveOnMain()
            .sink { requestedToDeleteAlert in
                self.requestedToDeleteAlert = requestedToDeleteAlert
            }
            .store(in: &self.cancelBag)
        
    }
    
}
