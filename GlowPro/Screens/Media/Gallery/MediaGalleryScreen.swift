//
//  MediaGalleryScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//

import SwiftUI

struct MediaGalleryScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: MediaGalleryViewModel
        
    var body: some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            topBar()
        } scrollViewContent: {
            content()
        }
        .safeAreaInset(edge: .bottom) {
            editModeBottomBar()
        }
        .emptyStateOverlay(
            shouldShow: self.viewModel.shouldShowEmptyState,
            config: self.viewModel.emptyStateConfig()
        )
        
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
        
        // On Change
        
        .onChange(of: self.viewModel.selectedPhotoPickerItems) { _, newValue in
            
            guard !newValue.isEmpty else { return }
            
            self.viewModel
                .handlePHPickerSelectionConverionToUIImage(items: newValue)
            
        }
        
        // Media Sheet
        
            .adaptiveSheet(
                isPresented: self.$viewModel.shouldShowMediaSourceSelectionSheet,
                additionalDetens: [],
                backgroundStyle: Style.shared.background(.primary)
            ) {
                
                MediaSourceSelectionView(sourceTypes: [.camera, .applePhotos],
                                         selectedSourceTypeAction: { source in
                    
                    self.viewModel
                        .handleSourceSelectionAction(source)
                    
                })
                .frame(maxWidth: .infinity)
                .presentationCornerRadius(Style.shared.radius(.large))
                .presentationCompactAdaptation(.popover)
                
            }
        
            .photosPicker(
                isPresented: self.$viewModel.shouldShowApplePhotosSelectionSheet,
                selection: self.$viewModel.selectedPhotoPickerItems,
                maxSelectionCount: 5,
                selectionBehavior: .ordered,
                matching: .images
            )
        
        // Animation
        
        .animation(.bouncy, value: self.viewModel.isEditMode)
        .animation(.bouncy, value: self.viewModel.editingMedia)
        
    }
    
    @ViewBuilder
    private func topBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        let trailingButtons = HStack {
            
            TokenView(text: "Edit")
                .asButton {
                    
                    let isEditMode = self.viewModel.isEditMode
                    
                    self.viewModel
                        .set(isEditMode: !isEditMode)
                    
                }
            
            if self.viewModel.shouldShowPlusButton {
                
                NavBarButton(style: .plus) {
                    
                    if let clientId = self.viewModel.mediaContext.clientId {
                        
                        if self.viewModel.mediaFilterOptions == .collage {
                            
                            self.navigationService
                                .push(.collage(.createEdit(
                                    clientId: clientId,
                                    collageId: nil
                                )))
                            
                        } else {
                            self.viewModel.shouldShowMediaSourceSelectionSheet = true
                        }
                        
                    }
                    
                }
                
            }
            
        }
        .asAnyView()

        NavBarView(
            title: self.viewModel.navTitle,
            leftButtonView: backButton,
            rightButtonView: trailingButtons
        )
        
    }
    
    @ViewBuilder
    private func filters() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            CommonDropDownMenu(
                options: MediaSortingOption.allCases,
                backgroundStyle: Style.shared.background(.primary),
                shadow: .none,
                textHorizontalPadding: .small,
                shouldPushContentDown: true,
                selectedOption: self.$viewModel.selectedSortingOption,
                showDropDown: self.$viewModel.showSortingDropdown
            )
            .appBorder(cornerRadius: .small, lineWidth: 1.5)
            
            WStack {
                
                ForEach(self.viewModel.mediaTags) { tag in
                    tagView(tag)
                }
                
            }
            
        }
        .zIndex(5000)
        .frame(maxWidth: .infinity)
        .background(Style.shared.background(.primary).source())
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        VStack(spacing: Style.shared.spacing(.large)) {
            
            filters()
            
            ForEach(self.viewModel.groups, id: \.id) { group in
                groupSection(group)
            }
            .padding(.top, -8)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, .medium)
        .animation(.snappy, value: self.viewModel.showSortingDropdown)
        .animation(.snappy, value: self.viewModel.selectedTags)
        .animation(.snappy, value: self.viewModel.selectedSortingOption)
        
    }
    
    private func groupSection(_ groupedMedia: MediaGalleryViewModel.GroupedMedia) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            sectionHeader(groupedMedia)
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
                spacing: 4
            ) {
                
                let placeholderView = PlaceholderView().asAnyView()
                
                ForEach(groupedMedia.media) { item in
                    
                    ImageSource.remote(
                        url: item.url,
                        placeholder: placeholderView,
                    )
                    .view(shouldResize: false)
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(.small)
                    .appOnTapGesture {
                        
                        self.viewModel
                            .select(item)
                        
                    }
                    .overlay(alignment: .topTrailing) {
                        
                        if self.viewModel.isEditMode {
                            
                            let isSelected = self.viewModel.editingMedia.contains(where: { $0.id == item.id })
                            editingView(isSelected: isSelected)
                            
                        }
                        
                    }
                    .overlay(alignment: .bottomTrailing) {
                        
                        if item.isFavorited && !self.viewModel.isEditMode {
                            favoriteView()
                        }
                        
                    }
                    
                }
                
            }
            
        }
        .id(groupedMedia.id)
        
    }
    
    private func sectionHeader(_ groupedMedia: MediaGalleryViewModel.GroupedMedia) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.extraSmall)) {
            
            HStack {
                
                Text(groupedMedia.title)
                    .appFont(with: .HEADER_2)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                let plural = groupedMedia.media.count == 1 ? "" : "s"
                Text("\(groupedMedia.media.count) photo\(plural)")
                    .appFont(with: .BODY_1)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                
            }
            
            Divider()
                .foregroundStyle(Style.shared.background(.quaternary).source())
            
        }
        
    }
    
    private func tagView(_ tag: MediaTag) -> some View {
        
        let isSelected = self.viewModel.selectedTags.contains(tag)
        
        return TokenView(
            text: tag.name.capitalized,
            foregroundStyle: isSelected ? Style.shared.textColor(.button) : Style.shared.textColor(.title),
            backgroundStyle: isSelected ? Style.shared.accent : .color(.clear),
            clipShape: .init(.rect(cornerRadius: Style.shared.radius(.extraSmall)))
        )
        .appBorder(
            cornerRadius: .extraSmall,
            color: isSelected ? Style.shared.accent : Style.shared.background(.border),
            lineWidth: 1.5
        )
        .appShadow(.subtle)
        .appOnTapGesture {
            self.viewModel.set(tag: tag)
        }
        
    }
    
    private func favoriteView() -> some View {
        
        Image(systemName: "star.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 18, height: 18)
            .foregroundStyle(GPColor.iconYellow)
            .padding(6)
            .background(.ultraThinMaterial, in: .circle)
            .padding([.bottom, .trailing], .small)
            .transition(.scale.combined(with: .opacity))
        
    }
    
    private func editingView(isSelected: Bool) -> some View {
        
        ZStack {
            
            Circle()
                .fill(.ultraThinMaterial)
                .appBorder(cornerRadius: .extraLarge, color: .color(.white))
            
            if isSelected {
                
                Circle()
                    .fill(Style.shared.accent.source())
                    .overlay {
                        
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(width: 12, height: 12)
                        
                    }
                    .transition(.scale.combined(with: .opacity))
                
            }
            
        }
        .frame(width: 24, height: 24)
        .clipShape(.circle)
        .padding([.top, .trailing], .small)
        .transition(.scale.combined(with: .opacity))
        
    }
    
    @ViewBuilder
    private func editModeBottomBar() -> some View {
        
        if self.viewModel.isEditMode && !self.viewModel.editingMedia.isEmpty {
            
            let pluralText = self.viewModel.editingMedia.count > 1 ? "s" : ""
            let title = "Edit Item\(pluralText) (\(self.viewModel.editingMedia.count))"
            
            CommonButton(title: title) {
                
                self.navigationService
                    .modal(fullScreenCover: .mediaMultiTags(
                        selectedMedia: self.viewModel.editingMedia)
                    )
                
                self.viewModel.set(isEditMode: false)
                
            }
            .padding(.top, .small)
            .padding(.horizontal, .medium)
            .transition(.move(edge: .bottom)
                .combined(with: .opacity)
                .animation(.smooth(duration: 0.3))
            )
            .background(Style.shared.background(.primary).source())
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(MediaGalleryViewModel.self)
        .setup(
            mediaContext: .business(businessId: MockModels.ID.business1),
            mediaSelectionContext: .preview
        )
    
    MediaGalleryScreen(viewModel: viewModel)
        .withMockServices()
    
}
