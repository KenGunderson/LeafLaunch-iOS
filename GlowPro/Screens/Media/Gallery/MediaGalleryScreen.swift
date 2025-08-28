//
//  MediaGalleryScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/20/25.
//
//WHTY IS NOT WORKING? PUSHING???
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
        
    }
    
    @ViewBuilder
    private func topBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        let filterButton = NavBarButton(style: .filter(isFilled: self.viewModel.showFilters)) {
            
            self.viewModel
                .set(showFilters: !self.viewModel.showFilters)
            
        }
        .asAnyView()
        
        NavBarView(
            title: "Photo Gallery",
            leftButtonView: backButton,
            rightButtonView: filterButton
        )
        
    }
    
    @ViewBuilder
    private func filters() -> some View {
     
        if self.viewModel.showFilters {
            
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
            .transition(.move(edge: .top).combined(with: .opacity))
            
        }
        
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
        .animation(.snappy, value: self.viewModel.showFilters)
        .animation(.snappy, value: self.viewModel.showSortingDropdown)
        .animation(.snappy, value: self.viewModel.selectedTags)
        .animation(.snappy, value: self.viewModel.selectedSortingOption)
        
    }
    
    private func groupSection(_ groupedMedia: MediaGalleryViewModel.GroupedMedia) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            sectionHeader(groupedMedia)
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 4),
                spacing: 4
            ) {
                
                let placeholderView = RoundedRectangle(cornerRadius: Style.shared.radius(.small))
                    .fill(Style.shared.background(.quaternary).source())
                    .overlay {
                        
                        AppLoadingView(style: .circleRunner(
                            color: Style.shared.background(.primary),
                            size: 24
                        ))
                        
                    }
                    .asAnyView()
                
                ForEach(groupedMedia.media) { item in
                    
                    ImageSource.remote(
                        url: item.url,
                        placeholder: placeholderView,
                    )
                    .view(shouldResize: false)
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(.small)
                    
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
        .onTapGesture {
            self.viewModel.set(tag: tag)
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(MediaGalleryViewModel.self)
        .setup(context: .business(businessId: MockModels.ID.business1))
    
    MediaGalleryScreen(viewModel: viewModel)
        .withMockServices()
    
}
