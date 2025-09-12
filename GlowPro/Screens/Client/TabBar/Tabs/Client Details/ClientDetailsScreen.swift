//
//  TabBar1Screen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

struct ClientDetailsScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: ClientDetailsViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    let tab: Tab
    
    var body: some View {
        
        let nav = Bindable(self.tabBarNavigationService)
        
        AppRootView(
            navigationService: nav.tab1NavigationService,
            alertService: nil) {
                
                AppHeaderScrollView(horizontalPadding: .none) {
                    navBarView()
                } scrollViewContent: {
                    content()
                }
                
                // Lifecycle
                
                .onFirstAppear {
                    
                    self.viewModel
                        .track()
                    
                    self.viewModel
                        .setup(tabBarNavigationService: self.tabBarNavigationService)
                    
                }
                
                .onAppear {
                    
                    self.tabBarNavigationService
                        .shouldShowTabBar(true)
                    
                }
                .task {
                    
                    self.viewModel
                        .loadData()
                    
                }
                
            }
            .tag(self.tab)
        
            .onChange(of: self.tabBarNavigationService.selectedTab) { oldValue, newValue in
                
                self.viewModel
                    .track(tab: newValue)
                
            }
        
            .onChange(of: self.viewModel.shouldDismiss) { _, newValue in
                
                guard newValue else { return }
                dismiss()
                
            }
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            if let client = viewModel.client {
            
                Group {
                    
                    profile(client)
                    media()
                    activities()
                    
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .animation(.smooth(duration: 0.4), value: self.viewModel.client)
        .animation(.smooth(duration: 0.4), value: self.viewModel.media)
        .animation(.smooth(duration: 0.4), value: self.viewModel.activities)
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        let closeButton = NavBarButton(style: .close) {
            dismiss()
        }
        .asAnyView()
        
        let trailingButtons = HStack {
            
            if self.viewModel.isOwnerOrManager {
                
                NavBarButton(style: .trash) {
                    
                    self.viewModel
                        .presentDeleteClientAlert()
                    
                }
                
            }
            
            NavBarButton(style: .pencil) {
                
                self.tabBarNavigationService
                    .shouldShowTabBar(false)
                
                self.tabBarNavigationService
                    .tab1NavigationService
                    .push(.client(.clientCreate(
                        locationId: self.viewModel.client?.locationId ?? "",
                        clientId: self.viewModel.client?.id)
                    ))
                
            }
            
        }
            .asAnyView()
        
        NavBarView(
            title: "Client Details",
            leftButtonView: closeButton,
            rightButtonView: trailingButtons
        )
        
    }
    
    @ViewBuilder
    private func profile(_ client: Client) -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Profile", showDivider: true)
            
            AppCardView {
                
                VStack(alignment: .leading) {
                    
                    label(
                        title: "First Name:",
                        value: client.firstName,
                        icon: "person.text.rectangle.fill"
                    )
 
                    label(
                        title: "Last Name:",
                        value: client.lastName,
                        icon: "person.text.rectangle.fill"
                    )
                    
                    if let email = client.email {
                        
                        label(
                            title: "Email:",
                            value: email,
                            icon: "envelope.fill"
                        )
                        
                    }
                    
                    if let phoneNumber = client.phoneNumber {
                        
                        label(
                            title: "Phone Number:",
                            value: phoneNumber.formatted(.phone(defaultCountryCode: nil)),
                            icon: "phone.fill"
                        )
                        
                    }
                    
                    if let dateOfBirth = client.dateOfBirth {
                        
                        label(
                            title: "Date Of Birth",
                            value: dateOfBirth.formatted(date: .long, time: .omitted),
                            icon: "calendar"
                        )
                        
                    }
                    
                }
                
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func media() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Media", showDivider: true) {
                
                self.tabBarNavigationService.tab1NavigationService.push(.media(
                    .gallery(.client(clientId: self.viewModel.clientId))
                ))
                
            }
            .padding(.horizontal, .medium)
            
            ScrollView(.horizontal) {
                
                LazyHStack {
                    
                    let placeholderView = PlaceholderView().asAnyView()
                    
                    ForEach(Array(self.viewModel.media.prefix(10)), id: \.id) { media in
                        
                        ImageSource.remote(
                            url: media.url,
                            placeholder: placeholderView,
                        )
                        .view(shouldResize: false)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 64)
                        .cornerRadius(.small)
                        
                    }
                    
                }
                .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func activities() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Activities", showDivider: true) {
                
                self.tabBarNavigationService.tab1NavigationService.push(.business(.businessActivitiesList(
                    context: .client(clientId: self.viewModel.clientId)
                )))
                
            }
            
            ActivitiesView(activities: Array(self.viewModel.activities.prefix(10)))
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    private func label(title: String,
                       value: String,
                       icon: String) -> some View {
        
        HStack(spacing: Style.shared.spacing(.small)) {
            
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundStyle(Style.shared.accent.source())
            
            Text(title)
                .appFont(with: .BODY_2)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
            Text(value)
                .appFont(with: .TITLE_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .padding(.leading, -2)
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(ClientDetailsViewModel.self)
        .setup(clientId: MockModels.ID.client1)
    
    ClientDetailsScreen(
        viewModel: viewModel,
        tab: .clientDetails
    )
    .withMockServices()
    
}
