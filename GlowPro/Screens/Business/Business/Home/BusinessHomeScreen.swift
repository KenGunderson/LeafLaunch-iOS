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
            
        }
        .task {
            
            self.viewModel
                .loadData(showsLoadingIndicator: self.viewModel.isFirstLoad)
            
        }
        
        // Sheets
        
        .adaptiveSheet(
            isPresented: self.$viewModel.shouldShowChecklistCompletionSheet,
            backgroundStyle: Style.shared.background(.primary)
        ) {
            ChecklistCompleteSheet()
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
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            tilesGrid()
            quickActionButtons()
            checklist()
            pendingInvitesList()
            activitiesList()
            
        }
        
    }
    
    @ViewBuilder
    private func tilesGrid() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            QuickActionTileView(
                icon: .systemImage("storefront.fill"),
                iconBackgroundColor: .color(GPColor.iconBlue),
                title: "Business Information",
                subtitle: self.viewModel.business?.address?.shortFormattedAddress ?? "No Address",
                prominentSubtitle: false
            )
            .appShadow(.subtle)
            .asButton {
                
                self.navigationService
                    .push(.business(
                        .businessCreateEdit(businessId: self.viewModel.businessId)
                    ))
                
            }
            
            LazyVGrid(columns: [
                .init(.flexible()),
                .init(.flexible()),
            ]) {
                
                QuickActionTileView(
                    icon: .systemImage("person.2.fill"),
                    iconBackgroundColor: .color(GPColor.iconGreen),
                    title: "All Employees",
                    subtitle: "\(self.viewModel.business?.totalEmployeeCount ?? 0)",
                    prominentSubtitle: true
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.business(.businessEmployees(
                            businessId: self.viewModel.businessId,
                            context: .business(businessId: self.viewModel.businessId))
                        ))
                    
                }
                
                QuickActionTileView(
                    icon: .systemImage("pin.fill"),
                    iconBackgroundColor: .color(GPColor.iconYellow),
                    title: "All Locations",
                    subtitle: "\(self.viewModel.business?.totalLocationCount ?? 0)",
                    prominentSubtitle: true
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.business(.businessLocationList(businessId: self.viewModel.businessId)))
                    
                }
                
                QuickActionTileView(
                    icon: .systemImage("person.3.fill"),
                    iconBackgroundColor: .color(GPColor.iconOrange),
                    title: "All Clients",
                    subtitle: "\(self.viewModel.business?.totalClientCount ?? 0)",
                    prominentSubtitle: true
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.client(.clientList(context: .business(businessId: self.viewModel.businessId))))
                    
                }
                
                QuickActionTileView(
                    icon: .systemImage("photo.on.rectangle.fill"),
                    iconBackgroundColor: .color(GPColor.iconPurple),
                    title: "All Media",
                    subtitle: "\(self.viewModel.business?.totalMediaCount ?? 0)",
                    prominentSubtitle: true
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.media(.gallery(.business(businessId: self.viewModel.businessId))))
                    
                }
                
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
                verticalPadding: .small2,
                horizontalPadding: .none) {
                    
                    self.navigationService
                        .push(.business(.businessEmployeesInvite(businessId: self.viewModel.businessId)))
                    
                }
            
            CommonButton(
                title: "Add New Location",
                titleFont: .TITLE_2,
                icon: .systemImage("plus"),
                verticalPadding: .small2,
                horizontalPadding: .none) {
                    
                    self.navigationService
                        .push(.business(.businessLocationCreateEdit(businessId: self.viewModel.businessId)))
                    
                }
            
        }
        
    }
    
    @ViewBuilder
    private func pendingInvitesList() -> some View {
        
        let pendingInvites = self.viewModel.business?.employeeInvites ?? []
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Pending Invites", showDivider: true) {
                
                self.navigationService
                    .push(.business(.businessEmployeeInviteList(
                        context: .business(businessId: self.viewModel.businessId))
                    ))
                
            }
            
            ForEach(pendingInvites, id: \.id) { invite in
                
                EmployeeInviteView(employeeInvitation: invite) {
                    self.viewModel.presentDeleteEmployeeInviteAlert(invite)
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func checklist() -> some View {
        
        if self.viewModel.showChecklist {
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                SectionView(leadingTitle: "First Steps", showDivider: true)
                
                ChecklistView(checklistItems: self.viewModel.checklistItems) { type in
                    self.viewModel.selectChecklistType(type: type)
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func activitiesList() -> some View {
        
        if !self.viewModel.activities.isEmpty {
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                SectionView(leadingTitle: "All Activities", showDivider: true) {
                    
                    self.navigationService
                        .push(.business(.businessActivitiesList(
                            context: .business(businessId: self.viewModel.businessId)
                        )))
                    
                }
                
                ActivitiesView(activities: Array(self.viewModel.activities.prefix(10)))
                
            }
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessHomeViewModel.self)
        .setup(businessId: MockModels.ID.business1)
    
    BusinessHomeScreen(viewModel: viewModel)
        .withMockServices()
    
}
