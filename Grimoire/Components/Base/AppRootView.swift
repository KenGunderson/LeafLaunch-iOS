//
//  AppRootView.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 6/21/25.
//

import SwiftUI

struct AppRootView<Content: View>: View {
    
    @Binding var navigationService: NavigationService
    private let content: Content
    
    init(navigationService: Binding<NavigationService>,
         @ViewBuilder content: () -> Content) {
        
        self._navigationService = navigationService
        self.content = content()
        
    }
    
    init(navigationService: Bindable<NavigationService>,
         @ViewBuilder content: () -> Content) {
        
        self._navigationService = .constant(navigationService.wrappedValue)
        self.content = content()
        
    }
    
    public var body: some View {
        
        NavigationStack(path: self.$navigationService.routes) {
            
            content
                .withNavigationDestination()
                .withSheetDestination(self.$navigationService.sheet)
                .withFullScreenCover(self.$navigationService.fullScreenCover)
            
        }
        
        // Env
        
        .environment(self.navigationService)
        
        // Dev Settings
        
        .simultaneousGesture(LongPressGesture(minimumDuration: 2.5).onEnded { _ in
            
            self.navigationService
                .modal(fullScreenCover: .devSettings)
            
        })
        
    }
    
}
