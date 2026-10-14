//
//  SplashScreenView.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 7/15/24.
//

import SwiftUI

struct SplashScreenView: View {
    
    @State private var isLoading: Bool = true
    private let didFinishAction: () -> ()
    
    init(didFinishAction: @escaping () -> ()) {
        self.didFinishAction = didFinishAction
    }
    
    var body: some View {
        
        SplashScreenIntroView(
            isLoading: self.$isLoading,
            text: "LeafLaunch"
        )
        .onChange(of: self.isLoading) { oldValue, newValue in
            
            if !newValue {
                self.didFinishAction()
            }
            
        }
        
    }
    
}

#Preview {
    
    SplashScreenView {
        print("Splash complete")
    }
    
}
