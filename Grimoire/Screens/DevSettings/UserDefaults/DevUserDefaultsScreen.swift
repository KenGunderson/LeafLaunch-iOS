//
//  DevUserDefaultsScreen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI
import Charts

struct DevUserDefaultsScreen: View {
    
    @StateObject var viewModel: DevUserDefaultsViewModel
    @Environment(NavigationService.self) private var navigationService
    
    var body: some View {
        
        AppHeaderScrollView {
            
            headerView()
            
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
        
    }
    
    @ViewBuilder
    private func headerView() -> some View {
        
        NavBarView(
            title: "User Defaults",
            leftButtonView: (
                BackButton {
                    self.viewModel.dismiss()
                }
            ).asAnyView()
        )
        
    }
    
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
         
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
        .appFont(with: .BODY_B10)
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
            
        }
        
    }
    
    @ViewBuilder
    private func data() -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.medium)) {
            
            outlineView(
                title: "Last Seen What's New Version",
                contentView: whatsNewVersion()
            )
            
            outlineView(
                title: "Themes",
                contentView: themeChoicesView()
            )
            
            if let data = self.viewModel.impersonatedUserData,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String : Any] {
                
                let contentView = JSONPreviewView(jsonData: json)
                    .padding(.horizontal, .medium)
                
                outlineView(
                    title: "Impersonating User",
                    contentView: contentView
                )
                
            }
            
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
                    foregroundStyle: Style.shared.textColor(.title),
                    backgroundStyle: Style.shared.accent
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
                    .appFont(with: .TITLE_T6)
                    .fontWeight(.heavy)
                
                contentView
                
            }
            .foregroundStyle(Style.shared.textColor(.title).source())
            
        }
        
    }
    
    @ViewBuilder
    private func outlineView(title: String,
                             contentView: some View) -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 0) {
                
                VStack(alignment: .leading) {
                    
                    Text(title)
                        .appFont(with: .TITLE_T6)
                        .fontWeight(.heavy)
                        .padding(.horizontal, Style.shared.spacing(.medium))
                    
                    contentView
                    
                }
                .padding(.vertical, .medium)
                
                Spacer(minLength: 0)
                
            }
            
        }
        .cornerRadius(Style.shared.radius(.small2))
        .overlay {
            
            RoundedRectangle(cornerRadius: Style.shared.radius(.small2))
                .stroke(Style.shared.background(.tertiary).source())
            
        }
        
    }
    
    private func themeChoicesView() -> some View {
        
        let selectedTheme = self.viewModel.theme
        
        return VStack(alignment: .leading,
                      spacing: Style.shared.spacing(.small)) {
            
            HStack(spacing: Style.shared.spacing(.none)) {
                
                Text("Selected Theme: ")
                    .appFont(with: .TITLE_T4)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
                let titleConversion = selectedTheme?.rawValue.convertNamingStyle(
                    from: .camelCase,
                    to: .sentenceCase
                )
                .capitalized
                
                Text(titleConversion ?? "N/A")
                    .appFont(with: .TITLE_T4)
                    .foregroundStyle(Style.shared.textColor(.body).source())
                
                Circle()
                    .fill(selectedTheme?.theme().foreground.primary.source() ?? AnyShapeStyle(Color.red))
                    .frame(width: 32, height: 32)
                    .padding(.horizontal, .small)
                
            }
            .padding(.horizontal, .medium)
            
            ScrollView(.horizontal) {
                
                HStack(spacing: Style.shared.spacing(.medium)) {
                    
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
                .padding(.horizontal, Style.shared.spacing(.medium))
                
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
                .appFont(with: .TITLE_T6)
                .fontWeight(.heavy)
            
            Circle()
                .fill(themeChoice.theme().foreground.primary.source())
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
