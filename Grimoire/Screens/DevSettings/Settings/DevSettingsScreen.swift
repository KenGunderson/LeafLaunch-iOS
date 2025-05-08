//
//  DevSettingsScreen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/25/24.
//

import SwiftUI

struct DevSettingsScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: DevSettingsViewModel
    @State private var navigationService = NavigationService()
            
    init(viewModel: DevSettingsViewModel) {
        
        self._viewModel = .init(wrappedValue: viewModel)
        setupPickerStyle()
        
    }
    
    var body: some View {
        
        NavigationStack(path: self.$navigationService.routes) {
            
            AppHeaderScrollView {
                
                navBarView()
                
            } scrollViewContent: {
                
                content()
                
            }
            .withNavigationDestination()
            .withSheetDestination(self.$navigationService.sheet)
            .withFullScreenCover(self.$navigationService.fullScreenCover)
            
            // Lifecycle
            
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel.setup(
                    navigationService: self.navigationService,
                    dismissAction: {
                        dismiss()
                    }
                )
                
            }
            
            // OnChange
            
            .onChange(of: self.viewModel.selectedEnviornment) { oldValue, newValue in
                self.viewModel.set(environment: newValue)
            }
            
        }
        .withAlertService(ObservableAlertServiceWrapper(alertService: self.viewModel.alertService))
        .withToastOverlay()
        
        // Env
        
        .environment(self.navigationService)
        .environmentObject(ObservableAlertServiceWrapper(alertService: self.viewModel.alertService))
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        NavBarView(
            title: "Dev Settings",
            rightButtonView: (
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .asButton {
                        
                        self.viewModel
                            .dismiss()
                        
                    }
                    .asAnyView()
            )
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: 24) {
            
            informationSection()
            routeSection()
            
        }
        .frame(maxWidth: .infinity)
        .animation(.smooth(duration: 0.4), value: self.viewModel.selectedEnviornment)
        
    }
    
    @ViewBuilder
    private func informationSection() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Information")
                .appFont(with: .TITLE_T5)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            AppCardView {
                
                VStack(spacing: Style.shared.spacing(.small)) {
                    
                    Picker("Enviornment", selection: self.$viewModel.selectedEnviornment) {
                        
                        ForEach(self.viewModel.getAppEnviornments(), id: \.displayName) { env in
                            Text(env.abbreviatedDisplayName.capitalized)
                                .appFont(with: .BODY_B5)
                                .foregroundStyle(Style.shared.textColor(.title).source())
                                .tag(env)
                        }
                        
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, .small)
                    
                    if case .custom = self.viewModel.selectedEnviornment {
                        
                        TextField("Title", text: self.$viewModel.customAPIEnviornmentPath)
                            .appFont(with: .TITLE_T4)
                            .foregroundStyle(Style.shared.textColor(.title).source())
                            .padding(8)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(uiColor: .lightGray), lineWidth: 1.5)
                            }
                            .onSubmit {
                                
                                let customEnv: AppEnvironment = .custom(address: self.viewModel.customAPIEnviornmentPath)
                                self.viewModel.set(environment: customEnv)
                                
                            }
                            .transition(
                                .move(edge: .top).combined(with: .opacity)
                            )
                            .padding(.bottom, .small)
                        
                    }
                    
                    lineItemView(
                        title: "Host",
                        subtitle: Constants.URLs.urlForEnvironment(self.viewModel.selectedEnviornment)
                    )
                    .padding(.bottom, .medium)
                    
                    lineItemView(
                        title: "Name",
                        subtitle: self.viewModel.user?.name ?? ""
                    )
                    
                    lineItemView(
                        title: "User Id",
                        subtitle: self.viewModel.user?.id ?? ""
                    )
                    
                    Text("Copy Auth Token")
                        .appFont(with: .TITLE_T6)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Style.shared.spacing(.small))
                        .padding(.vertical, Style.shared.spacing(.medium))
                        .background(.backgroundTappable)
                        .background {
                            
                            RoundedRectangle(cornerRadius: Style.shared.radius(.small))
                                .stroke(
                                    Style.shared.background(.tertiary).source(),
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
    private func routeSection() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Sections")
                .appFont(with: .TITLE_T5)
                .foregroundStyle(Style.shared.textColor(.title).source())
            
            VStack {
                
                ForEach(Route.DevSetting.allCases, id: \.rawValue) { route in
                    
                    listSectionItemView(
                        title: route.displayName,
                        icon: route.icon
                    )
                    .asButton {
                        
                        self.viewModel
                            .navigate(to: route.routeForDevSetting)
                        
                    }
                    
                }
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    func lineItemView(title: String,
                      subtitle: String) -> some View {
        
        HStack {
            
            Text(title + ": ")
                .appFont(with: .TITLE_T4)
            
            Spacer(minLength: 0)
            
            Text(subtitle)
                .appFont(with: .BODY_B4)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
        }
        .foregroundStyle(Style.shared.textColor(.title).source())
        
    }
    
    @ViewBuilder
    func listSectionItemView(title: String,
                             icon: String) -> some View {
        
        AppCardView {
            
            HStack {
                
                Label(
                    title,
                    systemImage: icon
                )
                
                Spacer(minLength: 0)
                
                Image(systemName: "chevron.right")
                
            }
            .foregroundStyle(Style.shared.accent.source())
            
        }
        
    }
    
    private func setupPickerStyle() {
        
        UISegmentedControl.appearance().backgroundColor = UIColor(Style.shared.background(.quaternary).asColor!)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Style.shared.accent.asColor!)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Style.shared.textColor(.title).asColor!)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Style.shared.textColor(.title).asColor!)], for: .normal)
        
    }
    
}

#Preview {
    
    DevSettingsScreen(
        viewModel: mockResolve(DevSettingsViewModel.self)
    )
    .withMockServices()
    
}
