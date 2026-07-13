//
//  DevLocalNotificationsScreen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/2/26.
//

import SwiftUI

struct DevLocalNotificationsScreen: GPView {

    @Environment(\.style) private var style
    
    @StateObject var viewModel: DevLocalNotificationsViewModel
    
    @State private var isModeDropdownPresented: Bool = false
    @State private var isPatternDropdownPresented: Bool = false
    @State private var isTimeSpanDropdownPresented: Bool = false
    @State private var isAnchoredCadenceDropdownPresented: Bool = false
    @State private var isAnchoredBoundaryDropdownPresented: Bool = false
    @State private var isCalendarCadenceDropdownPresented: Bool = false
    @State private var isCalendarMonthDropdownPresented: Bool = false
    
    @Environment(NavigationService.self) private var navigationService
    
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            
            headerView()
            
        } scrollViewContent: {
            
            content()
            
        }
        
        .onFirstAppear { [weak viewModel] in
            
            viewModel?
                .handleFirstAppear()
            
            viewModel?
                .setup(navigationService: self.navigationService)
            
        }
        
        .animation(.bouncy, value: self.isModeDropdownPresented)
        .animation(.bouncy, value: self.isPatternDropdownPresented)
        .animation(.bouncy, value: self.isTimeSpanDropdownPresented)
        .animation(.bouncy, value: self.isAnchoredCadenceDropdownPresented)
        .animation(.bouncy, value: self.isAnchoredBoundaryDropdownPresented)
        .animation(.bouncy, value: self.isCalendarCadenceDropdownPresented)
        .animation(.bouncy, value: self.isCalendarMonthDropdownPresented)
        .animation(.bouncy, value: self.viewModel.incomingNotifications)
        .animation(.bouncy, value: self.viewModel.plannedNotifications)
        
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
        
        VStack(spacing: self.style.spacing(.medium)) {
            
            permissionSection()
            schedulerSection()
            plannedSection()
            incomingSection()
            
        }
        
    }
    
    @ViewBuilder
    private func permissionSection() -> some View {
        
        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {
            
            Text("Permission")
                .appFont(with: .HEADER_2)
                .foregroundStyle(.text(.title))
            
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
            .foregroundStyle(.text(.body))
            
            VStack(spacing: self.style.spacing(.small)) {
                
                CommonButton(
                    title: self.viewModel.shouldPromptForPermissions ? "Request Permission" : "Request Again",
                    titleColor: .text(.button),
                    icon: .systemImage("bell.badge.fill"),
                    action: {
                        self.viewModel.requestPermission()
                    }
                )
                
                CommonButton(
                    title: "Refresh",
                    titleColor: .text(.button),
                    icon: .systemImage("arrow.clockwise"),
                    action: {
                        self.viewModel.refreshNotifications()
                    }
                )
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func schedulerSection() -> some View {
        
        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {
            
            Text("Scheduler")
                .appFont(with: .HEADER_2)
                .foregroundStyle(.text(.title))
            
            HStack(alignment: .top) {
                
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
                        self.closeAllDropdowns()
                        self.isModeDropdownPresented = true
                    }
                }
                
                CommonDropDownMenu(
                    options: self.viewModel.allPatternOptions,
                    backgroundStyle: .color(.minimumOpacity),
                    shadow: .none,
                    textHorizontalPadding: .small,
                    animation: .spring,
                    selectedOption: self.$viewModel.selectedPatternString,
                    showDropDown: self.$isPatternDropdownPresented
                )
                .appBorder(cornerRadius: .small, lineWidth: 1.5)
                .onChange(of: self.isPatternDropdownPresented) { _, isPresented in
                    if isPresented {
                        self.closeAllDropdowns()
                        self.isPatternDropdownPresented = true
                    }
                }
                
            }
            
            TextField("Every N", text: self.$viewModel.incrementalNumberText)
                .appFont(with: .TITLE_3)
                .foregroundStyle(.text(.title))
                .keyboardType(.numberPad)
                .padding(.horizontal, 8)
                .frame(height: 50)
                .appBorder(cornerRadius: .small, lineWidth: 1.5)
            
            if self.viewModel.shouldShowIntervalControls {
                
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
                        self.closeAllDropdowns()
                        self.isTimeSpanDropdownPresented = true
                    }
                }
                .transition(.blurReplace.combined(with: .opacity))
                
            }
            
            if self.viewModel.shouldShowAnchoredControls {
                
                CommonDropDownMenu(
                    options: self.viewModel.allAnchoredCadenceOptions,
                    backgroundStyle: .color(.minimumOpacity),
                    shadow: .none,
                    textHorizontalPadding: .small,
                    animation: .spring,
                    selectedOption: self.$viewModel.selectedAnchoredCadenceString,
                    showDropDown: self.$isAnchoredCadenceDropdownPresented
                )
                .appBorder(cornerRadius: .small, lineWidth: 1.5)
                .onChange(of: self.isAnchoredCadenceDropdownPresented) { _, isPresented in
                    if isPresented {
                        self.closeAllDropdowns()
                        self.isAnchoredCadenceDropdownPresented = true
                    }
                }
                .transition(.blurReplace.combined(with: .opacity))
                
                if self.viewModel.shouldShowAnchoredBoundaryControl {
                    
                    CommonDropDownMenu(
                        options: self.viewModel.allAnchoredBoundaryOptions,
                        backgroundStyle: .color(.minimumOpacity),
                        shadow: .none,
                        textHorizontalPadding: .small,
                        animation: .spring,
                        selectedOption: self.$viewModel.selectedAnchoredBoundaryString,
                        showDropDown: self.$isAnchoredBoundaryDropdownPresented
                    )
                    .appBorder(cornerRadius: .small, lineWidth: 1.5)
                    .onChange(of: self.isAnchoredBoundaryDropdownPresented) { _, isPresented in
                        if isPresented {
                            self.closeAllDropdowns()
                            self.isAnchoredBoundaryDropdownPresented = true
                        }
                    }
                    .transition(.blurReplace.combined(with: .opacity))
                    
                }
                
                self.timeFields()
                
            }
            
            if self.viewModel.shouldShowCalendarControls {
                
                CommonDropDownMenu(
                    options: self.viewModel.allCalendarCadenceOptions,
                    backgroundStyle: .color(.minimumOpacity),
                    shadow: .none,
                    textHorizontalPadding: .small,
                    animation: .spring,
                    selectedOption: self.$viewModel.selectedCalendarCadenceString,
                    showDropDown: self.$isCalendarCadenceDropdownPresented
                )
                .appBorder(cornerRadius: .small, lineWidth: 1.5)
                .onChange(of: self.isCalendarCadenceDropdownPresented) { _, isPresented in
                    if isPresented {
                        self.closeAllDropdowns()
                        self.isCalendarCadenceDropdownPresented = true
                    }
                }
                .transition(.blurReplace.combined(with: .opacity))
                
                if self.viewModel.shouldShowCalendarWeeklyControls {
                    
                    WStack {
                        
                        ForEach(self.viewModel.orderedWeekdays, id: \.self) { weekday in
                            
                            let isSelected = self.viewModel.selectedCalendarWeekdays.contains(weekday)
                            
                            TokenView(
                                text: weekday.shortDisplayName,
                                foregroundStyle: .text(isSelected ? .button : .title),
                                backgroundStyle: isSelected
                                ? .color(.indigo)
                                : .background(.quinary)
                            )
                            .asButton {
                                self.viewModel.toggleCalendarWeekday(weekday)
                            }
                            
                        }
                        
                    }
                    .transition(.blurReplace.combined(with: .opacity))
                    
                }
                
                if self.viewModel.shouldShowCalendarMonthlyControls {
                    
                    TextField("Day Of Month (1-31)", text: self.$viewModel.calendarDayOfMonthText)
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(.text(.title))
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 8)
                        .frame(height: 50)
                        .appBorder(cornerRadius: .small, lineWidth: 1.5)
                        .transition(.blurReplace.combined(with: .opacity))
                    
                }
                
                if self.viewModel.shouldShowCalendarYearlyControls {
                    
                    CommonDropDownMenu(
                        options: self.viewModel.allCalendarMonthOptions,
                        backgroundStyle: .color(.minimumOpacity),
                        shadow: .none,
                        textHorizontalPadding: .small,
                        animation: .spring,
                        selectedOption: self.$viewModel.selectedCalendarMonthString,
                        showDropDown: self.$isCalendarMonthDropdownPresented
                    )
                    .appBorder(cornerRadius: .small, lineWidth: 1.5)
                    .onChange(of: self.isCalendarMonthDropdownPresented) { _, isPresented in
                        if isPresented {
                            self.closeAllDropdowns()
                            self.isCalendarMonthDropdownPresented = true
                        }
                    }
                    .transition(.blurReplace.combined(with: .opacity))
                    
                    TextField("Day Of Month (1-31)", text: self.$viewModel.calendarYearDayOfMonthText)
                        .appFont(with: .TITLE_3)
                        .foregroundStyle(.text(.title))
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 8)
                        .frame(height: 50)
                        .appBorder(cornerRadius: .small, lineWidth: 1.5)
                        .transition(.blurReplace.combined(with: .opacity))
                    
                }
                
                self.timeFields()
                
            }
            
            Text(self.viewModel.schedulePreviewText)
                .appFont(with: .TITLE_5)
                .foregroundStyle(.text(.body))
            
            if !self.viewModel.nextOccurrencesPreviewText.isEmpty {
                
                Text(self.viewModel.nextOccurrencesPreviewText)
                    .appFont(with: .BODY_1)
                    .foregroundStyle(.text(.body))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.blurReplace.combined(with: .opacity))
                
            }
            
            CommonButton(
                title: "Schedule Notification",
                titleColor: .text(.button),
                icon: .systemImage("clock.badge.fill"),
                isEnabled: self.viewModel.isScheduleValid,
                action: {
                    self.viewModel.scheduleNotification()
                }
            )
            
            WStack {
                
                TokenView(
                    text: "Refresh Lists",
                    foregroundStyle: .text(.button),
                    backgroundStyle: .color(.indigo)
                )
                .asButton {
                    self.viewModel.refreshNotifications()
                }
                
                TokenView(
                    text: "Clear Planned",
                    foregroundStyle: .text(.button),
                    backgroundStyle: .color(.orange)
                )
                .asButton {
                    self.viewModel.clearPlannedNotifications()
                }
                
                TokenView(
                    text: "Clear Incoming",
                    foregroundStyle: .text(.button),
                    backgroundStyle: .color(.pink)
                )
                .asButton {
                    self.viewModel.clearIncomingNotifications()
                }
                
                TokenView(
                    text: "Clear All",
                    foregroundStyle: .text(.button),
                    backgroundStyle: .color(.red)
                )
                .asButton {
                    self.viewModel.clearAllNotifications()
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func timeFields() -> some View {
        
        HStack(spacing: self.style.spacing(.small)) {
            
            TextField("Hour (0-23)", text: self.$viewModel.anchorHourText)
                .appFont(with: .TITLE_3)
                .foregroundStyle(.text(.title))
                .keyboardType(.numberPad)
                .padding(8)
                .frame(height: 50)
                .appBorder(cornerRadius: .small, lineWidth: 1.5)
            
            TextField("Minute (0-59)", text: self.$viewModel.anchorMinuteText)
                .appFont(with: .TITLE_3)
                .foregroundStyle(.text(.title))
                .keyboardType(.numberPad)
                .padding(8)
                .frame(height: 50)
                .appBorder(cornerRadius: .small, lineWidth: 1.5)
            
        }
        
    }
    
    private func closeAllDropdowns() {
        
        self.isModeDropdownPresented = false
        self.isPatternDropdownPresented = false
        self.isTimeSpanDropdownPresented = false
        self.isAnchoredCadenceDropdownPresented = false
        self.isAnchoredBoundaryDropdownPresented = false
        self.isCalendarCadenceDropdownPresented = false
        self.isCalendarMonthDropdownPresented = false
        
    }
    
    @ViewBuilder
    private func plannedSection() -> some View {
        
        section(title: "Planned (\(self.viewModel.plannedNotifications.count))")
        
        if self.viewModel.plannedNotifications.isEmpty {
            
            emptyStateCard(message: "No planned notifications.")
                .transition(.blurReplace.combined(with: .scale))
            
        } else {
            
            ForEach(self.viewModel.plannedNotifications, id: \.id) { item in
                
                notificationItemView(item: item)
                    .transition(.blurReplace.combined(with: .scale))
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func incomingSection() -> some View {
        
        section(title: "Incoming (\(self.viewModel.incomingNotifications.count))")
        
        if self.viewModel.incomingNotifications.isEmpty {
            
            emptyStateCard(message: "No incoming notifications.")
                .transition(.blurReplace.combined(with: .scale))
            
        } else {
            
            ForEach(self.viewModel.incomingNotifications, id: \.id) { item in
                
                notificationItemView(item: item)
                    .transition(.blurReplace.combined(with: .scale))
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func section(title: String) -> some View {
        
        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {
            
            Text(title)
                .appFont(with: .HEADER_2)
                .foregroundStyle(.text(.title))
            
            Divider()
                .background(.text(.body))
            
        }
        
    }
    
    @ViewBuilder
    private func emptyStateCard(message: String) -> some View {
        
        AppCardView {
            
            Text(message)
                .appFont(with: .TITLE_5)
                .foregroundStyle(.text(.body))
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        
    }
    
    @ViewBuilder
    private func notificationItemView(item: LocalNotificationSnapshotItem) -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {
                
                HStack {
                    
                    Text(item.title)
                        .appFont(with: .TITLE_4)
                        .foregroundStyle(.text(.title))
                    
                    Spacer(minLength: 0)
                    
                    if item.isRepeating {
                        
                        TokenView(
                            text: "Repeats",
                            foregroundStyle: .text(.button),
                            backgroundStyle: .color(.indigo)
                        )
                        
                    }
                    
                }
                
                Text(item.body)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(.text(.body))
                
                if let date = item.date {
                    
                    Text(
                        date,
                        format: .dateTime.day().month().year().hour().minute().second()
                    )
                    .appFont(with: .BODY_1)
                    .foregroundStyle(.text(.body))
                    
                }
                
                Text(item.relativeDescription)
                    .appFont(with: .TITLE_5)
                    .foregroundStyle(.foreground(.primary))
                
                Text(item.id)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(.text(.body))
                
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
