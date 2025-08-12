//
//  LegalScreen.swift
//  GentlePath
//
//  Created by Sako Hovaguimian on 1/23/25.
//

import SwiftUI
import Charts

struct LegalScreen: View {
    
    @StateObject var viewModel: LegalViewModel
    @Environment(NavigationService.self) private var navigationService
            
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
                .loadData()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }

    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: self.viewModel.context.displayName,
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    private func content() -> some View {
        
        let items = self.viewModel.legalItems
        
        return VStack(alignment: .leading) {
            
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
                
                if !items.isEmpty {
                    
                    VStack(alignment: .leading,
                           spacing: Style.shared.spacing(.medium)) {
                        
                        ForEach(items, id: \.id) {
                            
                            self.section(legalItem: $0)
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    
                }
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .animation(.spring, value: self.viewModel.legalItems)
        
    }
    
    private func section(legalItem: LegalItem) -> some View {
        
        VStack(alignment: .leading,
               spacing: Style.shared.spacing(.small)) {
            
            Text(legalItem.title)
                .appFont(with: .HEADER_3)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.custom(6))) {
                
                ForEach(legalItem.sections, id: \.self) { message in
                    
                    Text(message)
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(LegalViewModel.self)
        .setup(context: .termsAndConditions)
    
    return LegalScreen(
        viewModel: viewModel
    )
    .withMockServices()
    
}
