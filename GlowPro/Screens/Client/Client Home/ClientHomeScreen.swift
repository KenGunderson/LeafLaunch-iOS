//
//  ClientHomeScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import SwiftUI

struct ClientHomeScreen: GPView {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationService.self) private var navigationService
    
    @StateObject private var viewModel: ClientHomeViewModel
    
    public init(viewModel: ClientHomeViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
        
    var body: some View {
                
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
                .setup(navigationService: self.navigationService)
            
        }

        .task {
            
            self.viewModel
                .loadData()
            
        }
        
        .onChange(of: self.viewModel.shouldDismiss) { _, newValue in
            
            guard newValue else { return }
            dismiss()
            
        }
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        NavHeader(
            title: self.viewModel.location?.name ?? "",
            subtitle: "Client Dashboard",
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { navItem in
                
                switch navItem {
                case .back: self.dismiss()
                default: fatalError("Not Implemented")
                }
                
            },
            trailingNavButtons: []
        )
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {
            
            if let client = viewModel.client {
            
                Group {
                    
                    tilesGrid(client: client)
                    quickActionButtons()
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
        
    }
    
    @ViewBuilder
    private func tilesGrid(client: Client) -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            QuickActionTileView(
                icon: .systemImage("person.fill"),
                iconBackgroundColor: .color(GPColor.iconBlue),
                title: client.fullName,
                subtitle: viewModel.buildSubtitleString(client: client),
                prominentSubtitle: false
            )
            .appShadow(.subtle)
            .asButton {
                
                self.navigationService
                    .push(.client(
                        .clientCreate(
                            locationId: client.locationId ?? "",
                            clientId: client.id
                        )))
                
            }
            
            LazyVGrid(columns: [
                .init(.flexible()),
                .init(.flexible()),
            ]) {
                
                QuickActionTileView(
                    icon: .systemImage("camera.fill"),
                    iconBackgroundColor: .color(GPColor.iconYellow),
                    title: "Camera",
                    subtitle: "Quick Photo Capture",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.media(.camera(
                            context: .client(clientId: client.id),
                            mode: .multiple([])
                        )))
                    
                }
                
                QuickActionTileView(
                    icon: .systemImage("photo.on.rectangle.fill"),
                    iconBackgroundColor: .color(GPColor.iconPurple),
                    title: "All Media",
                    subtitle: "Shows All Media",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.media(.gallery(.client(clientId: client.id))))
                    
                }
                
                QuickActionTileView(
                    icon: .image(.iconNoteOutline),
                    iconBackgroundColor: .color(GPColor.iconPink),
                    title: "All Notes",
                    subtitle: "Shows All Notes",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.media(.gallery(.client(clientId: client.id))))
                    
                }
                
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func quickActionButtons() -> some View {
     
        HStack {
            
            CommonButton(
                title: "Quick Note",
                titleFont: .TITLE_4,
                icon: .image(.iconNoteOutline),
                verticalPadding: .small2,
                horizontalPadding: .none) {
                    
                    // TODO: - FILL NOTE OUT
                    
                }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func media() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Recent Media", showDivider: true) {
                
                self.navigationService.push(.media(
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
                
                self.navigationService.push(.business(.businessActivitiesList(
                    context: .client(clientId: self.viewModel.clientId)
                )))
                
            }
            
            ActivitiesView(activities: Array(self.viewModel.activities.prefix(10)))
            
        }
        .padding(.horizontal, .medium)
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(ClientHomeViewModel.self)
        .setup(clientId: MockModels.ID.client1)
    
    ClientHomeScreen(
        viewModel: viewModel
    )
    .withMockServices()
    
}
