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
                case .back:
                    
                    self.viewModel.completion?()
                    self.dismiss()
                    
                default: fatalError("Not Implemented")
                }
                
            })
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            tilesGrid()
            buttonList()
            activitiesList()
            
        }
        
    }
    
    @ViewBuilder
    private func tilesGrid() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            QuickActionTileView(
                icon: .systemImage("storefront.fill"),
                iconBackgroundColor: .color(GPColor.iconBlue),
                title: "Location Information",
                subtitle: self.viewModel.business?.address?.shortFormattedAddress ?? "No Address",
                prominentSubtitle: false
            )
            .appShadow(.subtle)
            .asButton {
                
                self.navigationService
                    .push(.business(.businessLocationCreateEdit(
                        businessId: self.viewModel.business?.id ?? "",
                        locationId: self.viewModel.locationId
                    )))
                
            }
            
            LazyVGrid(columns: [
                .init(.flexible()),
                .init(.flexible()),
            ]) {
                
                QuickActionTileView(
                    icon: .systemImage("person.2.fill"),
                    iconBackgroundColor: .color(GPColor.iconGreen),
                    title: "Employees",
                    subtitle: "View All Employees",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    let businessId = self.viewModel.location?.businessId ?? ""
                    
                    self.navigationService
                        .push(.business(.businessEmployees(
                            businessId: businessId,
                            context: .location(locationId: self.viewModel.locationId))
                        ))
                    
                }
                
                QuickActionTileView(
                    icon: .systemImage("person.3.fill"),
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
                
                QuickActionTileView(
                    icon: .systemImage("camera.fill"),
                    iconBackgroundColor: .color(GPColor.iconYellow),
                    title: "Camera",
                    subtitle: "Quick Photo Capture",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.media(.camera(
                            context: .location(locationId: self.viewModel.locationId),
                            mode: .multiple([])
                        )))
                    
                }
                
                QuickActionTileView(
                    icon: .systemImage("photo.on.rectangle.fill"),
                    iconBackgroundColor: .color(GPColor.iconPurple),
                    title: "Photo Gallery",
                    subtitle: "View All Photos",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.media(.gallery(.location(locationId: self.viewModel.locationId))))
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func activitiesList() -> some View {
        
        if !self.viewModel.activities.isEmpty {
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                SectionView(leadingTitle: "All Activities", showDivider: true) {
                    
                    self.navigationService
                        .push(.business(.businessActivitiesList(
                            context: .location(locationId: self.viewModel.locationId)
                        )))
                    
                }
                
                ActivitiesView(activities: Array(self.viewModel.activities.prefix(10)))
                
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
        .setup(locationId: MockModels.ID.location1, completion: {})
    
    BusinessLocationHomeScreen(viewModel: viewModel)
        .withMockServices()
    
}
