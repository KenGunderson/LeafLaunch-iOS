//
//  FAQScreen.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 1/23/25.
//

import SwiftUI
import Charts

struct FAQScreen: GPView {
    
    @StateObject var viewModel: FAQViewModel
    @Environment(NavigationService.self) private var navigationService
    
    @State private var onAppearAnimation: Bool = false
            
    var body: some View {
        
        AppHeaderScrollView {
            headerView()
        } scrollViewContent: {
            content()
        }
        
        // Lifecycle
        
        .onFirstAppear {
            
            self.viewModel
                .track()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }
        .task {
            
            self.viewModel
                .loadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.onAppearAnimation = true
            }
            
        }

    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "Frequently Asked Questions",
            leftButtonView: (
                BackButton(backgroundColor: .color(.clear)) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        let config = StaggeredConfig.init(
            delay: 0.05,
            maxDelay: 0.05,
            blurRadius: 0.5,
            offset: .init(width: 0, height: 100),
            scale: 1,
            scaleAnchor: .center,
            animation: .smooth,
            disappearInSameDirection: true,
            noDisappearAnimation: false
        )
        
        StaggeredView(config: config) {
            
            if self.onAppearAnimation {
                
                ForEach(self.viewModel.faqItems, id: \.self) { item in
                    
                    faqItem(
                        title: item.title,
                        description: item.description
                    )
                    
                }
                
            }
            
        }
        
    }
    
    private func faqItem(title: String,
                         description: String) -> some View {
        
        CollapsableCardView(animation: .smooth) {
            
            Text(title)
                .appFont(with: .TITLE_T6)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
        } expandedView: {
            
            Text(description)
                .appFont(with: .BODY_B5)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .padding([.horizontal, .bottom], .medium)
            
        }
        
    }
    
}

#Preview {
    
    FAQScreen(
        viewModel: mockResolve(FAQViewModel.self)
    )
    .withMockServices()
    
}
