//
//  SplashScreenView.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI

struct SplashScreenView: View {
    
    @State private var isLoading: Bool = true
    private let didFinishAction: (LaunchScreenService.State) -> ()
    
    init(didFinishAction: @escaping (LaunchScreenService.State) -> ()) {
        self.didFinishAction = didFinishAction
    }
    
    var body: some View {
        
        SplashScreenItem(isLoading: self.$isLoading)
            .onChange(of: self.isLoading) { oldValue, newValue in
                
                if !newValue {
                    self.didFinishAction(.completed)
                }
                
            }
        
    }
    
}

#Preview {
    
    SplashScreenView { lauchState in
        print(lauchState)
    }
    
}
