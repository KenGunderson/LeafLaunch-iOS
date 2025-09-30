//
//  MockAssembly.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 7/23/24.
//

import SwiftUI
import Swinject

class MockAppAssembler {
    
    static let shared = MockAppAssembler()
    
    let assembler: Assembler
    
    var resolver: Resolver { self.assembler.resolver }

    private init() {
        
        self.assembler = Assembler([
            MockServiceAssembly(),
            MockViewModelAssembly()
        ])
        
        globalResolver = self.resolver
        
    }
    
}

private struct PreviewWrapper<Content: View>: View {
    
    let content: () -> Content
        
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        
        content()
            .withAlertService(ObservableAlertServiceWrapper(alertService: mockResolve(AlertServiceProtocol.self)))
        
    }
    
}

extension View {

    func withMockServices(withNaivgationService: Bool = true) -> some View {
        
        PreviewWrapper {
            self
        }
        .if(withNaivgationService) { view in
            view.environment(NavigationService())
        }
        .withToastOverlay()
        
    }
    
}

// Global function for resolving mock dependencies
func mockResolve<T>(_ type: T.Type) -> T {
    MockAppAssembler.shared.resolver.resolve(T.self)!
}
