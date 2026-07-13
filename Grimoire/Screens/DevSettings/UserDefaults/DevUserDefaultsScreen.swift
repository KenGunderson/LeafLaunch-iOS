//
//  DevUserDefaultsScreen.swift
//  Grimoire 
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI
import Charts

struct DevUserDefaultsScreen: GPView {

    @Environment(\.style) private var style
    
    @StateObject var viewModel: DevUserDefaultsViewModel
    @Environment(NavigationService.self) private var navigationService
    
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .medium) {
            
            headerView()
            
        } scrollViewContent: {
            
            content()
            
        }
        
        // Lifecycle
        
        .onFirstAppear { [weak viewModel] in
            
            viewModel?
                .handleFirstAppear()
            
            viewModel?
                .setup(navigationService: self.navigationService)
            
        }
        
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "User Defaults",
            leftButtonView: (
                NavBarButton(style: .back) {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    private func content() -> some View {
        
        VStack(spacing: self.style.spacing(.medium)) {
         
            sectionView(
                title: "Flags",
                contentView: flags()
            )
            
            sectionView(
                title: "Simulations",
                contentView: simulations()
            )
            
            sectionView(
                title: "Permissions (Read Only)",
                contentView: permissions()
            )
            .allowsHitTesting(false)
            
            sectionView(
                title: "Data",
                contentView: data()
            )
            
        }
        .appFont(with: .BODY_4)
        .onTapGesture {
            self.dismissKeyboard()
        }
        
    }
    
    @ViewBuilder
    private func permissions() -> some View {
        
        Toggle(isOn: Binding<Bool>(
            get: {
                self.viewModel.permissionService.cameraPermissionService.permissionGranted
            },
            set: { _ in }
        )) {
            Text("Camera Permissions")
        }
        
        Toggle(isOn: Binding<Bool>(
            get: {
                self.viewModel.permissionService.mediaPermissionService.permissionGranted
            },
            set: { _ in }
        )) {
            Text("Media Permissions")
        }
        
        Toggle(isOn: Binding<Bool>(
            get: {
                self.viewModel.permissionService.pushNotificationPermissionService.permissionGranted
            },
            set: { _ in }
        )) {
            Text("Push Notification Permissions")
        }
        
        Toggle(isOn: Binding<Bool>(
            get: {
                self.viewModel.permissionService.appTrackingPermissionService.permissionGranted ?? false
            },
            set: { _ in }
        )) {
            Text("App Tracking Permission")
        }
        
    }
    
    @ViewBuilder
    private func flags() -> some View {
        
        Group {
            
            Toggle("didCompleteOnboarding", isOn: self.$viewModel.didCompleteOnboarding)
            Toggle("didCompletePermission", isOn: self.$viewModel.didCompletePermission)
            Toggle("didRateMyAppAlertShow", isOn: self.$viewModel.didRateMyAppAlertShow)
            Toggle("shouldHideScreenshots", isOn: self.$viewModel.shouldHideScreenshots)
            
            HStack {
                
                TokenView(
                    text: "Reset Flags",
                    foregroundStyle: .color(.white),
                    backgroundStyle: .color(.red)
                )
                .asButton {
                    self.viewModel.resetDevFlags()
                }
                
                Spacer(minLength: 0)
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func data() -> some View {
        
        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {
            
            outlineView(
                title: "Last Seen What's New Version",
                contentView: whatsNewVersion()
            )
            
            outlineView(
                title: "Themes",
                contentView: themeChoicesView()
            )
            
        }
        
    }
    
    @ViewBuilder
    private func simulations() -> some View {
        
        Toggle("No Network", isOn: self.$viewModel.shouldShowNoNetworkError)
        Toggle("Force Update", isOn: self.$viewModel.shouldShowForceUpdateError)
        Toggle("Health Check", isOn: self.$viewModel.shouldShowHealthCheckError)
        
    }
    
    @ViewBuilder
    private func whatsNewVersion() -> some View {
        
        let lastViewedVersion = self.viewModel.lastViewedWhatsNewVersion ?? "nil"
        
        VStack(alignment: .leading) {
            
            TokenView(text: "Version: \(lastViewedVersion)")
        
            HStack {
                
                TokenView(
                    text: "Set To Latest",
                    foregroundStyle: .text(.button),
                    backgroundStyle: .foreground(.primary)
                )
                .asButton {
                    
                    let latestVersion = Constants.WhatsNewItems.items.last?.version.description
                    self.viewModel.lastViewedWhatsNewVersion = latestVersion
                    
                }
                
                TokenView(
                    text: "Reset",
                    foregroundStyle: .color(.white),
                    backgroundStyle: .color(.red)
                )
                .asButton {
                    self.viewModel.lastViewedWhatsNewVersion = nil
                }
                
            }
            
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .small)

    }
    
    @ViewBuilder
    private func sectionView(title: String,
                             contentView: some View) -> some View {
        
        AppCardView {
            
            VStack(alignment: .leading) {
                
                Text(title)
                    .appFont(with: .TITLE_5)
                    .fontWeight(.heavy)
                
                contentView
                
            }
            .foregroundStyle(.text(.title))
            
        }
        
    }
    
    @ViewBuilder
    private func outlineView(title: String,
                             contentView: some View) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 0) {
                
                VStack(alignment: .leading) {
                    
                    Text(title)
                        .appFont(with: .TITLE_5)
                        .fontWeight(.heavy)
                        .padding(.horizontal, self.style.spacing(.medium))
                    
                    contentView
                    
                }
                .padding(.vertical, .medium)
                
                Spacer(minLength: 0)
                
            }
            
        }
        .cornerRadius(self.style.radius(.small2))
        .overlay {
            
            RoundedRectangle(cornerRadius: self.style.radius(.small2))
                .stroke(.background(.tertiary))
            
        }
        
    }
    
    private func themeChoicesView() -> some View {
        
        let selectedTheme = self.viewModel.theme
        
        return VStack(alignment: .leading,
                      spacing: self.style.spacing(.small)) {
            
            HStack(spacing: self.style.spacing(.none)) {
                
                Text("Selected Theme: ")
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(.text(.body))
                
                let titleConversion = selectedTheme?.rawValue.convertNamingStyle(
                    from: .camelCase,
                    to: .sentenceCase
                )
                .capitalized
                
                Text(titleConversion ?? "N/A")
                    .appFont(with: .TITLE_3)
                    .foregroundStyle(.text(.body))
                
                Circle()
                    .fill(selectedTheme?.theme().foreground.primary ?? .color(.red))
                    .frame(width: 32, height: 32)
                    .padding(.horizontal, .small)
                
            }
            .padding(.horizontal, .medium)
            
            ScrollView(.horizontal) {
                
                HStack(spacing: self.style.spacing(.medium)) {
                    
                    ForEach(AvailableTheme.allCases, id: \.self) { themeChoice in
                        
                        themeChoiceView(themeChoice)
                        .asButton {
                            
                            withAnimation(.bouncy) {
                                
                                self.viewModel
                                    .set(theme: themeChoice)
                                
                            }
                            
                        }
                        
                    }
                    
                }
                .padding(.horizontal, self.style.spacing(.medium))
                
            }
            
        }
        
    }
    
    func themeChoiceView(_ themeChoice: AvailableTheme) -> some View {
        
        let titleConversion = themeChoice.rawValue.convertNamingStyle(
            from: .camelCase,
            to: .sentenceCase
        )
        .capitalized
        
        return VStack {
            
            Text(titleConversion)
                .appFont(with: .TITLE_5)
                .fontWeight(.heavy)
            
            Circle()
                .fill(themeChoice.theme().foreground.primary)
                .frame(width: 64, height: 64)
            
        }
        
    }
    
}

#Preview {
    
    DevUserDefaultsScreen(
        viewModel: mockResolve(DevUserDefaultsViewModel.self)
    )
    .withMockServices()
    
}
