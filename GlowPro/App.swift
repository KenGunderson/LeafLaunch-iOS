//
//  //  GlowPro App.swift
//  //  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

@main
struct GlowProApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var navigationService = NavigationService()
    
    private let appAssembler: AppAssembler = AppAssembler()
    private let rootViewModel: RootViewModel
    
    init() {
        
        self.rootViewModel = self.appAssembler
            .resolver
            .resolve(RootViewModel.self)!
        
    }
    
    var body: some Scene {
        
        WindowGroup {
            
            RootScreen(viewModel: self.rootViewModel)
                .onAppear {
                    
                    self.rootViewModel
                        .setup(
                            appDelegate: self.appDelegate,
                            navigationService: self.navigationService
                        )
                    
                }
            
        }
        
    }
    
}
