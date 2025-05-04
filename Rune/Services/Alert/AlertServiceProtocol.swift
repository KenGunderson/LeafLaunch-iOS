//
//  AlertServiceProtocol.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 8/5/24.
//

import Combine

protocol AlertServiceProtocol: AnyObject {
    
    var alerts: [Alert] { get }
    var alertsPublisher: AnyPublisher<[Alert], Never> { get }
    
    var requestedToDeleteAlert: Bool { get }
    var requestedToDeleteAlertPublisher: AnyPublisher<Bool, Never> { get }
    
    func showAlert(_ alert: Alert)
    func dismissAlert(_ alert: Alert)
    func dismiss(_ animated: Bool)
    func dismissAll()
    func dismissImmediately()
    func dismissLoadingIndicator()
    func setRequestToDeleteAlert(_ shouldRequest: Bool)
    
}
