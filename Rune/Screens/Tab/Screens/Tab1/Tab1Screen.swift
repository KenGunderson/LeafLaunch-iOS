//
//  TabBar1Screen.swift
//  Rune2
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

struct TabBar1Screen: View {
    
    @StateObject var viewModel: Tab1ViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    let tab: Tab
    
    var body: some View {
        
        let nav = Bindable(self.tabBarNavigationService.tab1NavigationService)
        
        NavigationStack(path: (nav.routes)) {
            
            content()
                .tag(self.tab)
            
            // Navigation
            
                .withNavigationDestination()
                .withSheetDestination(nav.sheet)
                .withFullScreenCover(nav.fullScreenCover)
            
            // Lifecycle
            
                .onFirstAppear {
                    
                    self.viewModel
                        .track()
                    
                    self.viewModel
                        .setup(tabBarNavigationService: self.tabBarNavigationService)
                    
                }
            
        }
        
    }
    
    private func content() -> some View {
        
        ContentView()
            .appOnTapGesture {
                self.viewModel.setRandomTheme()
            }
        
    }
    
}
