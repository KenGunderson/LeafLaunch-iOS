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
                
            })
            .contentTransition(.numericText())
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            if self.viewModel.business != nil {
                
                Group {
                    
                    mediaUsageOverageView()
                    
                    businessCardView()
                    checklist()
                    locationCardView()
                    
                    tilesGrid()
                    
                    pendingInvitesList()
//                    activitiesList()
//                    clientBirthdayList()
                    
                }
                .geometryGroup()
                .compositingGroup()
                .transition(.offset(y: 200).combined(with: .opacity))
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        
    }
    
    @ViewBuilder
    private func businessCardView() -> some View {
        
        let businessColor = ActivityCategory.business.color
        
        QuickActionTileHeaderView(
            icon: ActivityCategory.business.icon,
            iconBackgroundColor: .color(businessColor),
            title: self.viewModel.business?.name ?? "Business Information",
            subtitle: self.viewModel.business?.email ?? "Dashboard",
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
        
    }
    
    @ViewBuilder
    private func locationCardView() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(
                leadingTitle: "Operations",
                showDivider: true
            )
            
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
            
        }
        
    }
    
    @ViewBuilder
    private func tilesGrid() -> some View {
            
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            manageSection()
            assetsSection()
            settingsSection()
            
        }
        
    }
    
    @ViewBuilder
    private func manageSection() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(
                leadingTitle: "Team",
                showDivider: true
            )
            
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
                
//                QuickActionTileView(
//                    icon: ActivityCategory.client.icon,
//                    iconBackgroundColor: .color(ActivityCategory.client.color),
//                    title: "All Clients",
//                    subtitle: "\(self.viewModel.business?.totalClientCount ?? 0)",
//                    prominentSubtitle: true
//                )
//                .appShadow(.subtle)
//                .asButton {
//                    
//                    self.navigationService
//                        .push(.client(.clientList(context: .business(businessId: self.viewModel.businessId))))
//                    
//                }
                
            }
            
            inviteEmployeeView()
            
        }
        
    }
        
    @ViewBuilder
    private func assetsSection() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(
                leadingTitle: "Assets",
                showDivider: true
            )
            
            LazyVGrid(columns: [
                .init(.flexible()),
                .init(.flexible()),
            ]) {
                
                QuickActionTileView(
                    icon: ActivityCategory.media.icon,
                    iconBackgroundColor: .color(ActivityCategory.media.color),
                    title: "Favorited Media",
                    subtitle: "\(self.viewModel.business?.totalFavoritedMediaCount ?? 0)",
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
    private func settingsSection() -> some View {
        
        let isSubscribed = self.viewModel.business?.isSubscribed ?? false
        
        VStack(spacing: Style.shared.spacing(.small)) {
        
        SectionView(
            leadingTitle: "Account & Security",
            showDivider: true
        )
        
            HStack {
                
                QuickActionTileView(
                    icon: .systemImage("lock"),
                    iconBackgroundColor: .color(Color(uiColor: .lightGray)),
                    title: "Security",
                    subtitle: "Manage",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.setting(.businessSettings))
                    
                }
                
                QuickActionTileView(
                    icon: .systemImage("crown"),
                    iconBackgroundColor: Style.shared.accent,
                    title: isSubscribed ? "Subscription" : "Subscribe",
                    subtitle: isSubscribed ? "Manage Subscription" : "Get Started",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.viewModel
                        .presentSubscriptionPaywall()
                    
                }
                
            }
            
        }
        
    }
    
    private func inviteEmployeeView() -> some View {
        
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
        
    }
    
    private func addNewLocationView() -> some View {
        
        CommonButton(
            title: "Add New Location",
            titleFont: .TITLE_2,
            icon: .systemImage("plus"),
            verticalPadding: .small2,
            horizontalPadding: .none) {
                
                self.navigationService
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
                
                ActivitiesView(activities: Array(self.viewModel.activities.prefix(5)))
                
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
