//
//  TabBar1Screen.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

struct TabBar1Screen: View {

    @Environment(\.style) private var style
    
    @StateObject var viewModel: Tab1ViewModel
    @Environment(TabBarNavigationService.self) private var tabBarNavigationService
    
    let tab: Tab
    
    var body: some View {
        
        let nav = Bindable(self.tabBarNavigationService.tab1NavigationService)
        
        AppRootView(navigationService: nav) {
            
            AppHeaderScrollView(horizontalPadding: .medium) {
                
                navBarView()
                
            } scrollViewContent: {
                
                content()
                
            }
            .emptyStateOverlay(
                shouldShow: self.viewModel.shouldShowEmptyState,
                config: emptyStateConfig
            )
            // Lifecycle
            
            .onFirstAppear { [weak viewModel] in
                
                viewModel?
                    .track()
                
                viewModel?.setup(tabBarNavigationService: self.tabBarNavigationService)
                
            }
            .task { [weak viewModel] in
                
                viewModel?
                    .loadData(showHud: true)
                
            }
            
        }
        .tag(self.tab)
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        NavHeader(
            title: "",
            showLogo: true,
            trailingNavButtons: [
                .bell(notificationCount: 0),
                .settings
            ]
        ) { navItem in
            
            switch navItem {
            case .bell:
                
                ToastManager.shared
                    .present(toastItem: .init(title: "Some New Toast"))
                
                self.viewModel
                    .presentAlert()
                
            case .settings:
                
                self.tabBarNavigationService
                    .tab1NavigationService
                    .modal(fullScreenCover: .settings)
                
            default: fatalError("Not Implemented")
            }
            
        }
        .padding(.top, 1)
        .padding(.bottom, .custom(4))
        .overlay(alignment: .bottom) {
            
            Rectangle()
                .fill(.background(.quaternary))
                .frame(height: 1.5)
                .offset(y: self.style.spacing(.extraSmall))
            
        }
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        if self.viewModel.hasProjects {
            
            VStack(spacing: self.style.spacing(.medium)) {

                ForEach(self.viewModel.projects, id: \.self) { project in

                    GrimoireCardView(title: project) {

                        Text("This card and its actions are composed with app-owned components.")
                            .appFont(with: .BODY_3)
                            .foregroundStyle(.text(.body))

                        GrimoireButton(
                            title: "Remove Project",
                            icon: .systemImage("trash")
                        ) {

                            self.viewModel.remove(project: project)

                        }

                    }

                }

                GrimoireButton(
                    title: "Add Project",
                    icon: .systemImage("plus")
                ) {

                    self.viewModel.createProject()

                }

            }
            
        }
        
    }

    private var emptyStateConfig: EmptyStateConfig {

        .init(
            title: "No Projects",
            message: "Create a project from this empty state to see the populated list example.",
            image: .systemImage("square.stack.3d.up"),
            actionTitle: "Create Project",
            action: {

                self.viewModel.createProject()

            }
        )

    }
    
}

#Preview {
    
    let viewModel = mockResolve(Tab1ViewModel.self)
    
    TabBar1Screen(viewModel: viewModel, tab: .tab1)
        .withMockServices()
    
}
