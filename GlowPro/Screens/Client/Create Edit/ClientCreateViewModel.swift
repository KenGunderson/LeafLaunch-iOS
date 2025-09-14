//
//  ClientCreateViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/15/25.
//

import Combine



extension ClientCreateEditViewModel {
    
    func track() {
        
        self.analyticsService.track(screen: .client(.clientCreate))
        
    }
    
}
