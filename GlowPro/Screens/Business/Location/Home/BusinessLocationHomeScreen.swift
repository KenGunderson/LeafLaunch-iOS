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
                .loadData(showHud: self.viewModel.isFirstLoad)
            
        }
        
        // Sheet
        
        .onChange(of: self.viewModel.shouldShowSecurityScreen) { oldValue, newValue in
            
            guard !oldValue else { return }
            guard newValue else { return }
            
            self.navigationService
                .modal(sheet: .securityPin(
                    context: .validate,
                    businessId: self.viewModel.business?.id ?? "") { success in
                        
                        self.viewModel.shouldShowSecurityScreen = false
                        
                        guard success else { return }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.viewModel.dismiss()
                        }
                        
                    })
            
        }
        
        // Animation
        
        .animation(.snappy(duration: 0.5), value: self.viewModel.location)
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
                
        NavHeader(
            title: self.viewModel.business?.name ?? " ",
            subtitle: "Location Dashboard",
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { navItem in
                
                switch navItem {
                case .back:
                    
                    self.viewModel
                        .showSecurityPinSheetIfNeeded()
                    
                default: fatalError("Not Implemented")
                }
                
            })
        .contentTransition(.numericText())
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            if self.viewModel.location != nil {
                
                Group {
                    
                    tilesGrid()
                    buttonList()
                    
                    if self.viewModel.isOwnerOrManager {
                        pendingInvitesList()
                    }
                    
                    clientBirthdayList()
                    
                    activitiesList()
                    
                }
                .transition(.offset(y: 200).combined(with: .opacity))
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        
    }
    
    @ViewBuilder
    private func tilesGrid() -> some View {
        
        let location = self.viewModel.location
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            QuickActionTileView(
                icon: ActivityCategory.location.icon,
                iconBackgroundColor: .color(ActivityCategory.location.color),
                title: location?.name ?? "Location Information",
                subtitle: location?.address.shortFormattedAddress ?? "No Address",
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
                    icon: ActivityCategory.employee.icon,
                    iconBackgroundColor: .color(ActivityCategory.employee.color),
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
                    icon: ActivityCategory.client.icon,
                    iconBackgroundColor: .color(ActivityCategory.client.color),
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
                    icon: ActivityCategory.media.icon,
                    iconBackgroundColor: .color(ActivityCategory.media.color),
                    title: "Media Gallery",
                    subtitle: "View All Media",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.media(.gallery(
                            mediaContext: .location(locationId: self.viewModel.locationId),
                            mediaSelectionContext: .preview
                        )))
                    
                }
                
                QuickActionTileView(
                    icon: ActivityCategory.collage.icon,
                    iconBackgroundColor: .color(ActivityCategory.collage.color),
                    title: "Collages",
                    subtitle: "View All Collages",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.collage(.list(
                            context: .location(
                                locationId: self.viewModel.locationId
                            ))
                        ))
                    
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
                            context: .location(locationId: self.viewModel.locationId)
                        )))
                    
                }
                
                ActivitiesView(activities: Array(self.viewModel.activities.prefix(10)))
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func pendingInvitesList() -> some View {
        
        let pendingInvites = self.viewModel.pendingInvites
        
        if !pendingInvites.isEmpty {
                        
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                SectionView(leadingTitle: "Pending Invites", showDivider: true) {
                    
                    self.navigationService
                        .push(.business(.businessEmployeeInviteList(
                            context: .business(businessId: self.viewModel.location?.businessId ?? ""))
                        ))
                    
                }
                
                ForEach(pendingInvites, id: \.id) { invite in
                    
                    EmployeeInviteView(employeeInvitation: invite) {
                        self.viewModel.presentDeleteEmployeeInviteAlert(invite)
                    }
                    
                }
                
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
    
    @ViewBuilder
    private func clientBirthdayList() -> some View {
        
        let clientBirthdays = (self.viewModel
            .location?
            .clientsWithBirthdaysThisMonth ?? [])
            .sorted { ($0.dateOfBirthWithCurrentYear) < ($1.dateOfBirthWithCurrentYear) }
        
        if !clientBirthdays.isEmpty {
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                SectionView(leadingTitle: "Client Birthdays", showDivider: true)
                
                ForEach(clientBirthdays, id: \.self) { client in
                    ClientBirthdayView(client: client)
                }
                
            }
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessLocationHomeViewModel.self)
        .setup(locationId: MockModels.ID.location1, completion: {})
    
    BusinessLocationHomeScreen(viewModel: viewModel)
        .withMockServices()
    
}
