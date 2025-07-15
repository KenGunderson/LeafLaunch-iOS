//
//  BusinessActiveDestinationSelectionScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/13/25.
//

import SwiftUI

struct BusinessActiveDestinationSelectionScreen: GPView {
    
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: BusinessActiveDestinationSelectionViewModel
    
    var body: some View {
        
        content()
        
        // Lifecycle
        
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(tabBarNavigationService: self.tabBarNavigationService)
                
            }
            .onAppear {
                
                self.tabBarNavigationService
                    .shouldShowTabBar(false)
                
            }
            .task {
                
                self.viewModel
                    .loadData()
                
            }
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            contentCards()
        }
        
    }
    
    private func navBar() -> some View {
        
        let closeButton = CircularIconView(
            foregroundColor: .color(.black),
            backgroundColor: .color(.clear),
            imageSource: .systemImage("xmark"),
            size: 32
        )
        .asButton {
            dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Choose One:",
            rightButtonView: closeButton
        )
        .padding(.top, Style.shared.spacing(.medium))
        
    }
    
    
    private func contentCards() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            // Businesses
            
            sectionTitle("Businesses & Locations")
            businessList()
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func businessList() -> some View {
        
        ForEach(self.viewModel.businesses, id: \.id) { business in
            
            VStack(alignment: .leading,
                   spacing: Style.shared.spacing(.small)) {
                
                businessHeader(business)
                Divider()
                locationList(locations: business.locations)
                
            }
            
        }
        
    }
    
    private func businessHeader(_ business: Business) -> some View {
        
        HStack {
            
            Text(business.name)
                .appFont(with: .TITLE_T6)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if business.isOwner {
                
                CircularIconView(
                    foregroundColor: Style.shared.textColor(.title),
                    backgroundColor: Style.shared.background(.quaternary),
                    imageSource: .systemImage("arrow.right"),
                    size: 24
                )
                
            }
            
        }
        .appOnTapGesture {
            
            guard business.isOwner else { return }
            
            self.viewModel
                .selectBusiness(business)
            
        }
        
    }
    
    private func locationList(locations: [Location]) -> some View {
        
        VStack {
            
            ForEach(locations, id: \.id) { location in
                
                AppCardView {
                    
                    Text(location.name)
                        .appFont(with: .TITLE_T6)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                }
                .asButton {
                    
                    self.viewModel
                        .selectLocation(location)
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func sectionTitle(_ title: String) -> some View {
        
        Text(title)
            .foregroundStyle(Style.shared.textColor(.title).source())
            .appFont(with: .TITLE_T8)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessActiveDestinationSelectionViewModel.self)
    
    BusinessActiveDestinationSelectionScreen(viewModel: viewModel)
        .withMockServices()
    
}
