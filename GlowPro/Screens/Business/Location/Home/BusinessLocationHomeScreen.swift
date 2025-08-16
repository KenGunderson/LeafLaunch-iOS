//
//  BusinessLocationHomeScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/13/25.
//

import SwiftUI

struct BusinessLocationHomeScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationService.self) private var navigationService
    
    @StateObject private var viewModel: BusinessLocationHomeViewModel
    
    public init(viewModel: BusinessLocationHomeViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            
            navBarView()
            
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
            
        }
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        NavHeader(
            title: self.viewModel.business?.name ?? "",
            subtitle: self.viewModel.location?.name ?? "",
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { navItem in
                
                switch navItem {
                case .back: self.dismiss()
                default: fatalError("Not Implemented")
                }
                
            },
            trailingNavButtons: [.settings]) { navItem in
                
                switch navItem {
                case .settings: self.navigationService.modal(fullScreenCover: .settings)
                default: fatalError("Not Implemented")
                }
                
            }
            .padding(.bottom, .custom(4))
            .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            tilesGrid()
            buttonList()
            
        }
        
    }
    
    @ViewBuilder
    private func tilesGrid() -> some View {
        
        LazyVGrid(columns: [
            .init(.flexible()),
            .init(.flexible()),
        ]) {
            
            QuickActionTileView(
                icon: .systemImage("pin.fill"),
                iconBackgroundColor: .color(GPColor.iconBlue),
                title: "Location Info",
                subtitle: "54th Street Florida",
                prominentSubtitle: false
            )
            .appShadow(.subtle)
            .asButton {}
            
            QuickActionTileView(
                icon: .systemImage("camera.fill"),
                iconBackgroundColor: .color(GPColor.iconYellow),
                title: "Camera",
                subtitle: "Quick Photo Capture",
                prominentSubtitle: false
            )
            .appShadow(.subtle)
            .asButton {}
            
            QuickActionTileView(
                icon: .systemImage("photo.on.rectangle.fill"),
                iconBackgroundColor: .color(GPColor.iconPurple),
                title: "Photo Gallery",
                subtitle: "View All Photos",
                prominentSubtitle: false
            )
            .appShadow(.subtle)
            .asButton {}
            
            QuickActionTileView(
                icon: .systemImage("person.2.fill"),
                iconBackgroundColor: .color(GPColor.iconOrange),
                title: "Clients",
                subtitle: "View All Clients",
                prominentSubtitle: false
            )
            .appShadow(.subtle)
            .asButton {
                
                self.navigationService
                    .push(.client(.clientList(context: .location(locationId: self.viewModel.locationId))))
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func buttonList() -> some View {
        
        CommonButton(
            title: "Add New Client",
            icon: .systemImage("plus")
        ) {
            
            self.navigationService
                .push(.client(.clientCreate(locationId: self.viewModel.locationId)))
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessLocationHomeViewModel.self)
        .setup(locationId: MockModels.ID.location1)
    
    BusinessLocationHomeScreen(viewModel: viewModel)
        .withMockServices()
    
}
