//
//  DevLocalNotificationsScreen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/2/26.
//

import SwiftUI

struct DevLocalNotificationsScreen: GPView {
    
    @StateObject var viewModel: DevLocalNotificationsViewModel
    @State private var isModeDropdownPresented: Bool = false
    @State private var isTimeSpanDropdownPresented: Bool = false
    @Environment(NavigationService.self) private var navigationService
    
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            
            headerView()
            
        } scrollViewContent: {
            
            content()
            
        }
        
        .onFirstAppear {
            
            self.viewModel
                .handleFirstAppear()
            
            self.viewModel
                .setup(navigationService: self.navigationService)
            
        }
        
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "Local Notifications",
            subtitle: "Plan & Inspect Notifications",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            permissionSection()
            schedulerSection()
            plannedSection()
            incomingSection()
            
        }
        
    }
    
    @ViewBuilder
    private func permissionSection() -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                Text("Permission")
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                Text(
                    self.viewModel.isPermissionGranted
                    ? "Notifications are allowed."
                    : (
                        self.viewModel.shouldPromptForPermissions
                        ? "Permission has not been requested yet."
                        : "Notifications are currently denied."
                    )
                )
                .appFont(with: .TITLE_5)
                .foregroundStyle(Style.shared.textColor(.body).source())
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    
                    CommonButton(
                        title: self.viewModel.shouldPromptForPermissions ? "Request Permission" : "Request Again",
                        titleColor: Style.shared.textColor(.button),
                        icon: .systemImage("bell.badge.fill"),
                        action: {
                            self.viewModel.requestPermission()
                        }
                    )
                    
                    CommonButton(
                        title: "Refresh",
                        titleColor: Style.shared.textColor(.button),
                        icon: .systemImage("arrow.clockwise"),
                        action: {
                            self.viewModel.refreshNotifications()
                        }
                    )
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func schedulerSection() -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                
                Text("Scheduler")
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
                CommonDropDownMenu(
                    options: self.viewModel.allModeOptions,
                    backgroundStyle: .color(.minimumOpacity),
                    shadow: .none,
                    textHorizontalPadding: .small,
                    animation: .spring,
                    selectedOption: self.$viewModel.selectedModeString,
                    showDropDown: self.$isModeDropdownPresented
                )
                .appBorder(cornerRadius: .small, lineWidth: 1.5)
                .onChange(of: self.isModeDropdownPresented) { _, isPresented in
                    
                    if isPresented {
                        self.isTimeSpanDropdownPresented = false
                    }
                    
                }
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    
                    TextField("Incremental Number", text: self.$viewModel.incrementalNumberText)
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .keyboardType(.numberPad)
                        .padding(8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(uiColor: .lightGray), lineWidth: 1.5)
                        }
                    
                    CommonDropDownMenu(
                        options: self.viewModel.allTimeSpanOptions,
                        backgroundStyle: .color(.minimumOpacity),
                        shadow: .none,
                        textHorizontalPadding: .small,
                        animation: .spring,
                        selectedOption: self.$viewModel.selectedTimeSpanString,
                        showDropDown: self.$isTimeSpanDropdownPresented
                    )
                    .appBorder(cornerRadius: .small, lineWidth: 1.5)
                    .onChange(of: self.isTimeSpanDropdownPresented) { _, isPresented in
                        
                        if isPresented {
                            self.isModeDropdownPresented = false
                        }
                        
                    }
                    
                }
                
                Text(self.viewModel.schedulePreviewText)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
                CommonButton(
                    title: "Schedule Notification",
                    titleColor: Style.shared.textColor(.button),
                    icon: .systemImage("clock.badge.fill"),
                    isEnabled: self.viewModel.isScheduleValid,
                    action: {
                        self.viewModel.scheduleNotification()
                    }
                )
                
                VStack(alignment: .leading, spacing: Style.shared.spacing(.small)) {
                    
                    TokenView(
                        text: "Refresh Lists",
                        foregroundStyle: Style.shared.textColor(.button),
                        backgroundStyle: .color(.indigo)
                    )
                    .asButton {
                        self.viewModel.refreshNotifications()
                    }
                    
                    TokenView(
                        text: "Clear Planned",
                        foregroundStyle: Style.shared.textColor(.button),
                        backgroundStyle: .color(.orange)
                    )
                    .asButton {
                        self.viewModel.clearPlannedNotifications()
                    }
                    
                    TokenView(
                        text: "Clear Incoming",
                        foregroundStyle: Style.shared.textColor(.button),
                        backgroundStyle: .color(.pink)
                    )
                    .asButton {
                        self.viewModel.clearIncomingNotifications()
                    }
                    
                    TokenView(
                        text: "Clear All",
                        foregroundStyle: Style.shared.textColor(.button),
                        backgroundStyle: .color(.red)
                    )
                    .asButton {
                        self.viewModel.clearAllNotifications()
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func plannedSection() -> some View {
        
        section(title: "Planned (\(self.viewModel.plannedNotifications.count))")
        
        if self.viewModel.plannedNotifications.isEmpty {
            
            emptyStateCard(message: "No planned notifications.")
            
        } else {
            
            ForEach(self.viewModel.plannedNotifications, id: \.id) { item in
                notificationItemView(item: item)
            }
            
        }
        
    }
    
    @ViewBuilder
    private func incomingSection() -> some View {
        
        section(title: "Incoming (\(self.viewModel.incomingNotifications.count))")
        
        if self.viewModel.incomingNotifications.isEmpty {
            
            emptyStateCard(message: "No incoming notifications.")
            
        } else {
            
            ForEach(self.viewModel.incomingNotifications, id: \.id) { item in
                notificationItemView(item: item)
            }
            
        }
        
    }
    
    @ViewBuilder
    private func section(title: String) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
            
            Text(title)
                .appFont(with: .HEADER_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            Divider()
                .background(Style.shared.textColor(.body).source())
            
        }
        
    }
    
    @ViewBuilder
    private func emptyStateCard(message: String) -> some View {
        
        AppCardView {
            
            Text(message)
                .appFont(with: .TITLE_5)
                .foregroundStyle(Style.shared.textColor(.body).source())
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        
    }
    
    @ViewBuilder
    private func notificationItemView(item: LocalNotificationSnapshotItem) -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
                
                HStack {
                    
                    Text(item.title)
                        .appFont(with: .TITLE_4)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                    Spacer(minLength: 0)
                    
                    if item.isRepeating {
                        
                        TokenView(
                            text: "Repeats",
                            foregroundStyle: Style.shared.textColor(.button),
                            backgroundStyle: .color(.indigo)
                        )
                        
                    }
                    
                }
                
                Text(item.body)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
                if let date = item.date {
                    
                    Text(
                        date,
                        format: .dateTime.day().month().year().hour().minute().second()
                    )
                    .appFont(with: .BODY_1)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                    
                }
                
                Text(item.relativeDescription)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(Style.shared.accent.source())
                
                Text(item.id)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
            }
            
        }
        
    }
    
}

#Preview {
    
    DevLocalNotificationsScreen(
        viewModel: mockResolve(DevLocalNotificationsViewModel.self)
    )
    .withMockServices()
    
}
