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
                .loadData(showHud: self.viewModel.isFirstLoad)
            
        }
        
        .onChange(of: self.viewModel.shouldDismiss) { _, newValue in
            
            guard newValue else { return }
            dismiss()
            
        }
        
        // Animation
        
        .animation(.snappy(duration: 0.5), value: self.viewModel.client)
        
    }
    
    @ViewBuilder
    private func navBarView() -> some View {
        
        NavHeader(
            title: self.viewModel.location?.name ?? " ",
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
        .contentTransition(.numericText())
        
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
                .transition(.offset(y: 200).combined(with: .opacity))
                
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
                icon: ActivityCategory.client.icon,
                iconBackgroundColor: .color(ActivityCategory.client.color),
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
                    icon: ActivityCategory.note.icon,
                    iconBackgroundColor: .color(ActivityCategory.note.color),
                    title: "All Notes",
                    subtitle: "Show All Notes",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.note(.noteList(clientId: client.id)))
                    
                }
                
                QuickActionTileView(
                    icon: ActivityCategory.form.icon,
                    iconBackgroundColor: .color(ActivityCategory.form.color),
                    title: "All Forms",
                    subtitle: "Show All Forms",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    // TODO: - FILL OUT
                    
                }
                
                QuickActionTileView(
                    icon: ActivityCategory.camera.icon,
                    iconBackgroundColor: .color(ActivityCategory.camera.color),
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
                    icon: ActivityCategory.media.icon,
                    iconBackgroundColor: .color(ActivityCategory.media.color),
                    title: "All Media",
                    subtitle: "Show All Media",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.media(.gallery(
                            mediaContext: .client(clientId: client.id),
                            mediaSelectionContext: .preview
                        )))
                    
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
                    
                    self.navigationService
                        .push(.note(.noteCreateEdit(
                            context: .create,
                            clientId: self.viewModel.clientId)
                        ))
                    
                }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func media() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            SectionView(leadingTitle: "Recent Media", showDivider: true) {
                
                self.navigationService.push(.media(.gallery(
                    mediaContext: .client(clientId: self.viewModel.clientId),
                    mediaSelectionContext: .preview
                )))
                
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
                        .contentShape(.rect(cornerRadius: Style.shared.radius(.small)))
                        .asButton {
                            
                            self.navigationService
                                .modal(fullScreenCover: .mediaPreview(
                                    url: media.url
                                ))
                            
                        }
                        
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
