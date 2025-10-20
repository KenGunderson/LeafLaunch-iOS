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
    
    @FocusState private var isFocused: Bool
    
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
        
        // Tap
        
        .onTapGesture {
            self.isFocused = false
        }
        
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
                    summary()
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
                
                QuickActionTileView(
                    icon: ActivityCategory.collage.icon,
                    iconBackgroundColor: .color(ActivityCategory.collage.color),
                    title: "All Collages",
                    subtitle: "Show All Collages",
                    prominentSubtitle: false
                )
                .appShadow(.subtle)
                .asButton {
                    
                    self.navigationService
                        .push(.collage(.list(
                            context: .client(clientId: self.viewModel.clientId)
                        )))
                    
                }
                
            }
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func summary() -> some View {
        
        VStack(spacing: Style.shared.spacing(.custom(6))) {
            
            CollapsableView(isExpanded: self.$viewModel.clientSummaryExpanded,
                            backgroundColor: .color(.clear),
                            collapsedView: {
                
                VStack(spacing: Style.shared.spacing(.extraSmall)) {
                    
                    HStack {
                        
                        Text("Summary")
                            .appFont(with: .TITLE_6)
                            .foregroundStyle(Style.shared.textColor(.title).source())
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "chevron.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Style.shared.textColor(.body).source())
                            .frame(width: 16)
                            .rotationEffect(self.viewModel.clientSummaryExpanded ? .degrees(0) : .degrees(180))
                        
                    }
                    
                    Capsule()
                        .fill(Style.shared.background(.quaternary).source())
                        .frame(height: 1.5)
                    
                }
                .padding(.horizontal, .medium)
                .background(.clear)
                
            }, expandedView: {
                
                VStack {
                    
                    CommonTextEditView(
                        text: self.$viewModel.clientSummaryText,
                        placehoderText: "Client Summary...",
                        isFocused: self.isFocused,
                        titleFont: .BODY_3,
                        unselectedBorderColor: .color(.clear),
                        backgroundStyle: .color(.clear),
                        cornerRadius: .small,
                        shadow: .none,
                        lineLimit: 8...20,
                        verticalPadding: .small,
                        horizontalPadding: .small
                    )
                    .focused(self.$isFocused)
                    .appBorder(
                        cornerRadius: .small,
                        color: self.isFocused ? Style.shared.accent : Style.shared.background(.border),
                        lineWidth: 1.5
                    )
                    .onSubmit {
                        self.viewModel.clientSummaryText += "\n"
                    }
                    
                }
                .padding(.top, .small)
                .padding(.horizontal, .medium)
                .padding(.bottom, .extraSmall)
                
            })
            .background(.clear)
            
            if self.viewModel.hasClientSummaryChanged {
                
                CommonButton(title: "Update Summary") {
                    
                    self.viewModel
                        .updateClientSummary()
                    
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .opacity
                ))
                .padding(.horizontal, .medium)
                
            }
            
        }
        .animation(.smooth, value: self.viewModel.clientSummaryExpanded)
        .animation(.smooth, value: self.viewModel.hasClientSummaryChanged)

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
