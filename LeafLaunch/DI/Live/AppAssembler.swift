//
//  AppAssembler.swift
//  SwiftyUI
//
//  Created by Sako Hovaguimian on 7/12/24.
//

import Foundation
import FactoryKit

class AppAssembler {
    
    let container: Container
    
    init() {

        self.container = Container.shared

#if LEAFLAUNCH_MOCK
        MockServiceAssembly().assembleRuntime(container: self.container)
#endif

    }
    
}
