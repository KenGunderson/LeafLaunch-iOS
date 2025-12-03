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
                .loadData(showHud: self.viewModel.isFirstLoad)
            
        }
        
        // Sheets
        
        .adaptiveSheet(
            isPresented: self.$viewModel.shouldShowChecklistCompletionSheet,
            backgroundStyle: Style.shared.background(.primary)
        ) {
            ChecklistCompleteSheet()
        }
        
        // Animation
        
        .animation(.snappy(duration: 0.5), value: self.viewModel.business)
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        NavHeader(
            title: "Business Dashboard",
            subtitle: self.viewModel.business?.name ?? " ",
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
            .contentTransition(.numericText())
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            if self.viewModel.business != nil {
                
                Group {
                    
                    mediaUsageOverageView()
                    checklist()
                    tilesGrid()
                    quickActionButtons()
                    pendingInvitesList()
                    clientBirthdayList()
                    activitiesList()
                    
                }
                .transition(.offset(y: 200).combined(with: .opacity))
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        
    }
    
    @ViewBuilder
    private func tilesGrid() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            let businessColor = ActivityCategory.business.color
            
            QuickActionTileView(
                icon: ActivityCategory.business.icon,
                iconBackgroundColor: .color(businessColor),
                title: self.viewModel.business?.name ?? "Business Information",
                subtitle: self.viewModel.business?.email ?? "Dashboard",
                prominentSubtitle: false,
                backgroundStyle: .color(businessColor.opacity(0.10))
            )
            .appShadow(.subtle)
            .appBorder(
                cornerRadius: .small,
                color: .color(businessColor),
                lineWidth: 2
            )
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
                    icon: ActivityCategory.employee.icon,
                    iconBackgroundColor: .color(ActivityCategory.employee.color),
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
                    icon: ActivityCategory.location.icon,
                    iconBackgroundColor: .color(ActivityCategory.location.color),
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
                    icon: ActivityCategory.client.icon,
                    iconBackgroundColor: .color(ActivityCategory.client.color),
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
                    icon: ActivityCategory.media.icon,
                    iconBackgroundColor: .color(ActivityCategory.media.color),
                    title: "All Media",
                    subtitle: "\(self.viewModel.business?.totalMediaCount ?? 0)",
                    prominentSubtitle: true
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.media(.gallery(
                            mediaContext: .business(businessId: self.viewModel.businessId),
                            mediaSelectionContext: .preview
                        )))
                    
                }
                
                QuickActionTileView(
                    icon: ActivityCategory.tags.icon,
                    iconBackgroundColor: .color(ActivityCategory.tags.color),
                    title: "All Media Tags",
                    subtitle: "\(self.viewModel.business?.totalMediaTagCount ?? 0)",
                    prominentSubtitle: true
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .modal(fullScreenCover: .mediaTags(
                            selectedMedia: nil
                        ))
                    
                }
                
                QuickActionTileView(
                    icon: ActivityCategory.form.icon,
                    iconBackgroundColor: .color(ActivityCategory.form.color),
                    title: "All Forms",
                    subtitle: "\(self.viewModel.business?.totalFormsCount ?? 0)",
                    prominentSubtitle: true
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.form(.formList(
                            context: .business(businessId: self.viewModel.businessId),
                            mode: .preview
                        )))
                    
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
                        .push(.business(
                            .businessEmployeesInvite(
                                businessId: self.viewModel.businessId,
                                context: .newEmployee
                            )))
                    
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
        
        if !pendingInvites.isEmpty {
            
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
    
    @ViewBuilder
    private func clientBirthdayList() -> some View {
        
        let clientBirthdays = (self.viewModel
            .business?
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
    
    @ViewBuilder
    private func mediaUsageOverageView() -> some View {
        
        if let business = self.viewModel.business,
           let usage = business.stripeSubscriptionOverageUsage,
           usage.mediaUsagePercentage >= 0.80 {

            let color = ActivityCategory.media.color
            let percentage = Float(usage.mediaUsagePercentage)
            
            SectionCardView(
                title: "Media Usage",
                subtitle: "You're almost at your monthly limit. Click here to learn more.",
                icon: .systemImage("camera.fill"),
                color: .color(color)
            ) {
                
                VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                    
                    Text(usage.mediaUsagePercentage, format: .percent.precision(.fractionLength(0)))
                        .appFont(with: .TITLE_4)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    ProgressBar(
                        value: .constant(percentage),
                        fillColor: .color(color)
                    )
                    .frame(height: 12)
                    .frame(maxHeight: 12)
                    .appShadow(.card)
                    
                    HStack {
                        
                        Text("Used: \(usage.mediaUsed)")
                            .appFont(with: .TITLE_4)
                            .foregroundStyle(Style.shared.textColor(.body).source())
                        
                        Spacer()
                        
                        Text("Allowed: \(usage.mediaAllowed)")
                            .appFont(with: .TITLE_4)
                            .foregroundStyle(Style.shared.textColor(.body).source())
                        
                    }
                    
                    Text("Resets: \(Date.getNextBillingDate())")
                        .appFont(with: .BODY_2)
                        .foregroundStyle(Style.shared.textColor(.body).source())
                    
                }
                
            }
            .asButton {
                
                self.navigationService
                    .modal(fullScreenCover: .subscriptionManage(
                        businessId: self.viewModel.businessId)
                    )
                
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(BusinessHomeViewModel.self)
        .setup(businessId: MockModels.ID.business1)
    
    BusinessHomeScreen(viewModel: viewModel)
        .withMockServices()
    
}
