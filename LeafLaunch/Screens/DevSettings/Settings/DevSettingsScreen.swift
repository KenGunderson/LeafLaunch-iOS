//
//  DevSettingsScreen.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI

struct DevSettingsScreen: GPView {

    @Environment(\.style) private var style
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DevSettingsViewModel
    @State private var navigationService = NavigationService()
    @State private var shouldShowComponentsView: Bool = false
    
    init(viewModel: DevSettingsViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        AppRootView(navigationService: self.$navigationService) {
            
            AppHeaderScrollView(horizontalPadding: .medium) {
                
                navBarView()
                
            } scrollViewContent: {
                
                content()
                
            }
            // Lifecycle
            
            .onFirstAppear { [weak viewModel] in
                
                viewModel?
                    .handleFirstAppear()
                
                viewModel?.setup(
                    navigationService: self.navigationService,
                    dismissAction: {
                        dismiss()
                    }
                )
                
            }
            
            // OnChange
            
            .onChange(of: self.viewModel.selectedEnviornment!) { oldValue, newValue in
                self.viewModel.set(environment: newValue)
            }
            
            // Full Screen Cover
            .fullScreenCover(isPresented: self.$shouldShowComponentsView) {
                DemoView()
            }
            
        }
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        let closeButton = NavBarButton(style: .close) {
            self.viewModel.dismiss()
        }
            .padding(.trailing, .small)
            .asAnyView()
        
        NavBarView(
            title: "Dev Settings",
            rightButtonView: closeButton
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: 24) {
            
            informationSection()
            diagnosticsSection()
            routeSection()
            
        }
        .frame(maxWidth: .infinity)
        .animation(.smooth(duration: 0.4), value: self.viewModel.selectedEnviornment)
        
    }
    
    @ViewBuilder
    private func informationSection() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Information")
                .appFont(with: .TITLE_4)
                .foregroundStyle(.text(.title))
            
            AppCardView {
                
                VStack(spacing: self.style.spacing(.small)) {
                    
                    CommonSegmentedControl(
                        selectedOption: self.$viewModel.selectedEnviornment,
                        options: self.viewModel.getAppEnviornments(),
                        selectedTextColor: .text(.titleInverted)
                    )
                    .padding(.bottom, .small)
                    
                    if case .custom = self.viewModel.selectedEnviornment {
                        
                        TextField("Title", text: self.$viewModel.customAPIEnviornmentPath)
                            .appFont(with: .TITLE_3)
                            .foregroundStyle(.text(.title))
                            .padding(8)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(uiColor: .lightGray), lineWidth: 1.5)
                            }
                            .onSubmit { [weak viewModel] in
                                
                                let customEnv: AppEnvironment = .custom(address: viewModel?.customAPIEnviornmentPath ?? "")
                                viewModel?.set(environment: customEnv)
                                
                            }
                            .transition(
                                .move(edge: .top).combined(with: .opacity)
                            )
                            .padding(.bottom, .small)
                        
                    }
                    
                    lineItemView(
                        title: "Host",
                        subtitle: Constants.URLs.urlForEnvironment(self.viewModel.selectedEnviornment!)
                    )
                    .padding(.bottom, .medium)
                    
                    lineItemView(
                        title: "Name",
                        subtitle: self.viewModel.user?.fullName ?? ""
                    )
                    
                    lineItemView(
                        title: "User Id",
                        subtitle: self.viewModel.user?.id ?? ""
                    )
                    
                    Text("Copy Auth Token")
                        .appFont(with: .TITLE_5)
                        .foregroundStyle(.text(.title))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, self.style.spacing(.small))
                        .padding(.vertical, self.style.spacing(.medium))
                        .background(.backgroundTappable)
                        .background {
                            
                            RoundedRectangle(cornerRadius: self.style.radius(.small))
                                .stroke(
                                    .background(.tertiary),
                                    lineWidth: 2
                                )
                            
                        }
                        .asButton {
                            self.viewModel.copyAuthTokenToNotepad()
                        }
                        .padding(.top, .small)
                    
                }
                
            }
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
    @ViewBuilder
    private func diagnosticsSection() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Diagnostics")
                .appFont(with: .TITLE_4)
                .foregroundStyle(.text(.title))
            
            AppCardView {
                
                VStack(spacing: self.style.spacing(.small)) {
                    
                    lineItemView(
                        title: "Version",
                        subtitle: self.viewModel.appVersion
                    )
                    
                    lineItemView(
                        title: "Build",
                        subtitle: self.viewModel.buildNumber
                    )
                    
                    lineItemView(
                        title: "Bundle Id",
                        subtitle: self.viewModel.bundleIdentifier
                    )
                    
                    lineItemView(
                        title: "Environment",
                        subtitle: self.viewModel.currentEnvironmentName
                    )
                    
                    lineItemView(
                        title: "Device Id",
                        subtitle: self.viewModel.deviceId
                    )
                    
                    lineItemView(
                        title: "FCM Registration Token",
                        subtitle: self.viewModel.pushToken
                    )
                    
                    lineItemView(
                        title: "User Email",
                        subtitle: self.viewModel.currentUserEmail
                    )
                    
                }
                
            }
            
        }
        .frame(maxWidth: .infinity)
        
    }
    
    @ViewBuilder
    private func routeSection() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Sections")
                .appFont(with: .TITLE_4)
                .foregroundStyle(.text(.title))
            
            VStack {
                
                listSectionItemView(
                    title: "Components",
                    icon: "wrench.and.screwdriver.fill"
                )
                .asButton {
                    self.shouldShowComponentsView = true
                }
                
                ForEach(Route.DevSettingRoute.allCases, id: \.rawValue) { route in
                    
                    listSectionItemView(
                        title: route.displayName,
                        icon: route.icon
                    )
                    .asButton {
                        
                        self.viewModel
                            .navigate(to: route.routeForDevSetting)
                        
                    }
                    
                }
                
                if self.viewModel.firebaseService.user != nil {
                    
                    listSectionItemView(
                        title: "Logout",
                        icon: "person.fill",
                        colorOverride: .palette(.error)
                    )
                    .asButton {
                        
                        self.viewModel
                            .logout()
                        
                    }
                    
                }
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    func lineItemView(title: String,
                      subtitle: String) -> some View {
        
        HStack(alignment: .top) {
            
            Text(title + ": ")
                .appFont(with: .TITLE_3)
            
            Spacer(minLength: 0)
            
            Text(subtitle)
                .appFont(with: .BODY_2)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
        }
        .foregroundStyle(.text(.title))
        
    }
    
    @ViewBuilder
    func listSectionItemView(title: String,
                             icon: String,
                             colorOverride: ColorSource = .foreground(.primary)) -> some View {
        
        AppCardView {
            
            HStack {
                
                Label(
                    title,
                    systemImage: icon
                )
                
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.right")
                
            }
            .foregroundStyle(colorOverride)
            
        }
        
    }
    
}

#Preview {
    
    DevSettingsScreen(
        viewModel: mockResolve(DevSettingsViewModel.self)
    )
    .withMockServices(withNaivgationService: false)
    
}
