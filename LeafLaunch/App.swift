//
//  App.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI
import FactoryKit

@main
struct LeafLaunchApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    private let appAssembler: AppAssembler = AppAssembler()
    private let rootViewModel: RootViewModel
    
    init() {
        
        self.rootViewModel = self.appAssembler
            .container
            .rootViewModel()
        
    }
    
    var body: some Scene {
        
        WindowGroup {
            
            RootScreen(viewModel: self.rootViewModel)
                .onAppear { [weak rootViewModel] in
                    
                    rootViewModel?
                        .setup(appDelegate: self.appDelegate)
                    
                }
                .runeStyle()
            
        }
        
    }
    
}
