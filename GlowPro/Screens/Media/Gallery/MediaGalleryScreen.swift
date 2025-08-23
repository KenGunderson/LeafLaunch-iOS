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
                    backgroundStyle: .color(.minimumOpacity),
                    shadow: .none,
                    textHorizontalPadding: .small,
                    shouldPushContentDown: true,
                    selectedOption: self.$viewModel.selectedSortingOption,
                    showDropDown: self.$viewModel.showSortingDropdown
                )
                .appBorder(cornerRadius: .small, lineWidth: 1.5)
                
                WStack {
                    
                    tagView("Tag 1")
                    tagView("Tag 2")
                    tagView("Tag 3")
                    tagView("Tag 4")
                    tagView("Tag 5")
                    tagView("Tag 6")
                    tagView("Tag 7")
                    
                }
                
            }
            .zIndex(5000)
            .frame(maxWidth: .infinity)
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
        .padding(.horizontal, .medium)
        .animation(.snappy, value: self.viewModel.showFilters)
        
    }
    
    private func groupSection(_ groupedMedia: MediaGalleryViewModel.GroupedMedia) -> some View {
        
        VStack(alignment: .leading, spacing: Style.shared.spacing(.small2)) {
            
            sectionHeader(groupedMedia)
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 5),
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
    
    private func tagView(_ tag: String) -> some View {
        
        let isSelected = self.viewModel.selectedTags.contains(tag)
        
        return TokenView(
            text: tag,
            foregroundStyle: isSelected ? Style.shared.textColor(.button) : Style.shared.textColor(.title),
            backgroundStyle: isSelected ? Style.shared.accent : .color(.clear),
        )
        .appBorder(
            cornerRadius: .custom(99),
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
