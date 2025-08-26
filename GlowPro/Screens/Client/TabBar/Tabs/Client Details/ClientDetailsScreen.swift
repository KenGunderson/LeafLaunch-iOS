//
//  TabBar1Screen.swift
//  GlowPro 
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

enum ClientActionItem: String, CaseIterable {
    
    case notes
    case forms
    case folders
    case proposals
    case media
    case collages
    case activity
    case edit
    
    var displayName: String {
        self.rawValue.capitalized
    }
    
    var systemIcon: String {
        switch self {
        case .notes: return "pencil"
        case .forms: return "text.document.fill"
        case .folders: return "folder.fill"
        case .proposals: return "dollarsign.circle.fill"
        case .media: return "photo.on.rectangle.fill"
        case .collages: return "grid"
        case .activity: return "magnifyingglass"
        case .edit: return "square.and.pencil"
        }
    }
    
}

struct ClientDetailsScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: ClientDetailsViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    let tab: Tab
    
    var body: some View {
        
        let nav = Bindable(self.tabBarNavigationService)
        
        AppRootView(
            navigationService: nav.tab1NavigationService,
            alertService: self.viewModel.alertService) {
                
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
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: 24) {
            
            if let client = viewModel.client {
                
                AppCardView {
                    
                    Text(client.fullName)
                        .appFont(with: .HEADER_2)
                        .foregroundStyle(Style.shared.textColor(.title).source())
                    
                }
                .asButton {
                    dismiss()
                }
                .transition(.move(edge: .bottom))
                
                actionItems()
                activityFilters()
                activities()
                
            }
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .animation(.smooth(duration: 0.4), value: self.viewModel.client)
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        let pencilButton = NavBarButton(style: .pencil) {
            
            self.tabBarNavigationService
                .shouldShowTabBar(false)
            
            self.tabBarNavigationService
                .tab1NavigationService
                .push(.client(.clientCreate(
                    locationId: nil,
                    clientId: self.viewModel.client?.id)
                ))
            
        }
        .asAnyView()
        
        NavBarView(
            title: "Client Details",
            rightButtonView: pencilButton
        )
        
    }
    
    @ViewBuilder
    private func actionItems() -> some View {
        
        LazyVGrid(columns: [.init(.adaptive(minimum: 80, maximum: 80), spacing: 8, alignment: .center)], spacing: 4) {
            
            ForEach(ClientActionItem.allCases, id: \.self) { action in
                
                actionItem(
                    title: action.displayName,
                    icon: action.systemIcon,
                    action: {}
                )
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func activityFilters() -> some View {
        
        TokenView(
            text: "Toggle Activity",
            foregroundStyle: Style.shared.textColor(.button),
            backgroundStyle: Style.shared.accent
        )
        .asButton {
            self.viewModel.selectedActivitiesFilter = (self.viewModel.selectedActivitiesFilter == nil) ? "1" : nil
        }
        
    }
    
    @ViewBuilder
    private func activities() -> some View {
        
        let activities: [Activity] = [
            .init(
                id: "1",
                title: "Called Client",
                clientId: "",
                authorId: "",
                createdAt: Date().addingTimeInterval(-73497493).toISO()
            ),
            .init(
                id: "2",
                title: "Intake Form Filled",
                clientId: "",
                authorId: "",
                createdAt: Date().addingTimeInterval(-4379743).toISO()
            ),
            .init(
                id: "3",
                title: "Ate At Outback",
                clientId: "",
                authorId: "",
                createdAt: Date().addingTimeInterval(-4379743).toISO()
            ),
            .init(
                id: "4",
                title: "Did Something Else",
                clientId: "",
                authorId: "",
                createdAt: Date().toISO()
            ),
            .init(
                id: "5",
                title: "Built Legos",
                clientId: "",
                authorId: "",
                createdAt: Date().toISO()
            ),
            .init(
                id: "6",
                title: "Ate Some Soup",
                clientId: "",
                authorId: "",
                createdAt: Date().toISO()
            ),
        ]
        
        ActivitiesView(
            activities: self.viewModel.selectedActivitiesFilter == nil ? activities : activities.suffix(3)
        )
        .animation(.spring, value: self.viewModel.selectedActivitiesFilter)
        
    }
    
    private func actionItem(title: String,
                            icon: String,
                            action: @escaping () -> Void) -> some View {
        
        VStack {
            
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            Text(title)
                .appFont(with: .TITLE_3)
            
        }
        .foregroundStyle(Style.shared.textColor(.titleInverted).source())
        .frame(width: 80, height: 80)
        .background(Style.shared.accent.asColor!.gradient)
        .clipShape(.rect(cornerRadius: Style.shared.radius(.medium)))
        .asButton {
            action()
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
