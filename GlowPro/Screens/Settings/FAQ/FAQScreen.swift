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
        
        AppHeaderScrollView(horizontalPadding: .medium) {
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
                NavBarButton(style: .back) {
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
            animation: .smooth.delay(0.3),
            interitemSpacing: 16,
            disappearInSameDirection: true,
            noDisappearAnimation: false
        )
        
        StaggeredView(config: config) {
            
            if !self.viewModel.faqItems.isEmpty {
                
                ForEach(self.viewModel.faqItems, id: \.title) { item in
                    section(item: item)
                }
                
            }
            
        }
        
    }
    
    private func section(item: FAQViewModel.FAQItemSection) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            Text(item.title)
                .appFont(with: .TITLE_6)
                .foregroundStyle(Style.shared.accent.source())
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                ForEach(item.sections, id: \.question) { section in
                    
                    cardView(
                        title: section.question,
                        description: section.answer
                    )
                    
                }
                
            }
            
        }
        
    }
    
    private func cardView(title: String,
                          description: String) -> some View {
        
        FAQItemView(
            question: title,
            answer: description,
        )
        
    }
    
}

#Preview {
    
    FAQScreen(
        viewModel: mockResolve(FAQViewModel.self)
    )
    .withMockServices()
    
}
