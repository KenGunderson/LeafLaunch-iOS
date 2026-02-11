//
//  //  Grimoire App.swift
//  //  Grimoire 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI
import FactoryKit

@main
struct GrimoireApp: App {
    
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
                .onAppear {
                    
                    self.rootViewModel
                        .setup(appDelegate: self.appDelegate)
                    
                }
            
        }
        
    }
    
}
