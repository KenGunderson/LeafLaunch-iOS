//
//  BusinessHomeScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/13/25.
//

import SwiftUI

struct BusinessHomeScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationService.self) private var navigationService
    
    @StateObject private var viewModel: BusinessHomeViewModel
    
    public init(viewModel: BusinessHomeViewModel) {
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
            
            self.viewModel
                .loadData()
            
        }
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        NavHeader(
            title: self.viewModel.business?.name ?? "",
            subtitle: "Business Dashboard",
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
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            tilesGrid()
            
            quickActionButtons()
                .padding(.top, .small)
            
            pendingInvites()
                .padding(.top, .medium)
            
        }
        
    }
    
    @ViewBuilder
    private func tilesGrid() -> some View {
        
        LazyVGrid(columns: [
            .init(.flexible()),
            .init(.flexible()),
        ]) {
            
            QuickActionTileView(
                icon: .systemImage("person.2.fill"),
                iconBackgroundColor: .color(GPColor.iconGreen),
                title: "All Clients",
                subtitle: "\(self.viewModel.business?.clientsCount ?? 0)",
                prominentSubtitle: true
            )
            .appShadow(.subtle)
            .asButton {
                
                self.navigationService
                    .push(.client(.clientList(context: .business(businessId: self.viewModel.businessId))))
                
            }
            
            QuickActionTileView(
                icon: .systemImage("pin.fill"),
                iconBackgroundColor: .color(GPColor.iconBlue),
                title: "All Locations",
                subtitle: "\(self.viewModel.business?.locations.count ?? 0)",
                prominentSubtitle: true
            )
            .appShadow(.subtle)
            .asButton {
                
                self.navigationService
                    .push(.business(.businessLocations(businessId: self.viewModel.businessId)))
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func quickActionButtons() -> some View {
     
        HStack {
            
            CommonButton(
                title: "Invite Employee",
                titleFont: .TITLE_2,
                icon: .systemImage("plus"),
                verticalPadding: .custom(10),
                horizontalPadding: .none) {
                    
                    self.navigationService
                        .push(.business(.businessEmployeesInvite(businessId: self.viewModel.businessId)))
                    
                }
            
            CommonButton(
                title: "Add New Location",
                titleFont: .TITLE_2,
                icon: .systemImage("plus"),
                verticalPadding: .custom(10),
                horizontalPadding: .none) {
                    
                    self.navigationService
                        .push(.business(.businessLocationCreateEdit(businessId: self.viewModel.businessId)))
                    
                }
            
        }
        
    }
    
    @ViewBuilder
    private func pendingInvites() -> some View {
     
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            section(title: "Pending Invites")
            
        }
        
    }
    
    @ViewBuilder
    private func section(title: String) -> some View {
     
        VStack(alignment: .leading) {
            
            HStack {
                
                Text(title)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(Rune.Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    
                    Text("View All")
                        .appFont(with: .BODY_1)
                    
                    Image(systemName: "arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12)
                    
                }
                .foregroundStyle(Rune.Style.shared.textColor(.body).source())
                .asButton {
                    
                    self.navigationService
                        .push(.business(.businessEmployeeInviteList(
                            context: .business(businessId: self.viewModel.businessId))
                        ))
                    
                }
                
            }
            
            Divider()
                .background(Style.shared.background(.border).source())
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessHomeViewModel.self)
        .setup(businessId: MockModels.ID.business1)
    
    BusinessHomeScreen(viewModel: viewModel)
        .withMockServices()
    
}
