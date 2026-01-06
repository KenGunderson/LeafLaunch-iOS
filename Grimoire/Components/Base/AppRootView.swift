//
//  AppRootView.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 6/21/25.
//

import SwiftUI

struct AppRootView<Content: View>: View {
    
    @Binding var navigationService: NavigationService
//    private let alertService: AlertServiceProtocol?
//    @State var observableAlertServiceWrapper: ObservableAlertServiceWrapper?
    private let content: Content
    
    init(navigationService: Binding<NavigationService>,
         alertService: AlertServiceProtocol? = nil,
         @ViewBuilder content: () -> Content) {
        
        self._navigationService = navigationService
        
//        self.alertService = alertService
//        self.observableAlertServiceWrapper = (alertService == nil) ? nil : .init(alertService: alertService!)
        
        self.content = content()
        
    }
    
    init(navigationService: Bindable<NavigationService>,
         alertService: AlertServiceProtocol? = nil,
         @ViewBuilder content: () -> Content) {
        
        self._navigationService = .constant(navigationService.wrappedValue)
        
//        self.alertService = alertService
//        self.observableAlertServiceWrapper = (alertService == nil) ? nil : .init(alertService: alertService!)
        
        self.content = content()
        
    }
    
    public var body: some View {
     
        NavigationStack(path: self.$navigationService.routes) {
            
            content
                .withNavigationDestination()
                .withSheetDestination(self.$navigationService.sheet)
                .withFullScreenCover(self.$navigationService.fullScreenCover)
            
        }
        
//        // Alert
//        
//        .if(self.alertService != nil) { view in
//            view.withAlertService(self.observableAlertServiceWrapper!)
//        }
//        
//        // Toast
//        
//        .withToastOverlay()
        
        // Env
        
        .environment(self.navigationService)
//        
//        .if(self.alertService != nil) { view in
//            view.environmentObject(self.observableAlertServiceWrapper!)
//        }
        
        // Dev Settings
        
        .simultaneousGesture(LongPressGesture(minimumDuration: 2.5).onEnded { _ in
            
            self.navigationService
                .modal(fullScreenCover: .devSettings)
            
        })
        
    }
    
}
