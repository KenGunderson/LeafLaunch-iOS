//
//  MediaPreviewScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/31/25.
//

import SwiftUI

struct MediaPreviewScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var viewModel: MediaPreviewViewModel
    
    var body: some View {
        
        content()
        
        // Lifecycle
        
            .onFirstAppear {
                
                self.viewModel
                    .track()
                
                self.viewModel
                    .setup(navigationService: self.navigationService)
                
            }
        
        // Sheets
        
            .adaptiveSheet(
                isPresented: self.$viewModel.shouldShowOptionsSheet,
                backgroundStyle: Style.shared.background(.primary)
            ) {
                
                optionsSheet()
                    .presentationCornerRadius(Style.shared.radius(.large))
                
            }
        
    }
    
    private func content() -> some View {
        
        AppBaseView {
            selectedMedia()
        }
        .safeAreaInset(edge: .top) {
            navBar()
        }
        .safeAreaInset(edge: .bottom) {
            
            if !self.viewModel.isSingleMedia {
                mediaList()
            }
            
        }
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        let isFavorited = self.viewModel.selectedMedia?.isFavorited ?? false
        
        let favoriteButtons = NavBarButton(
            style: .star(isFilled: self.viewModel.selectedMedia?.isFavorited ?? false),
            foregroundColor: isFavorited ? .color(GPColor.iconYellow) : Rune.Style.shared.textColor(.title)
        ) {
            self.viewModel.favoriteMedia()
        }

        let ellipseButton = NavBarButton(style: .ellipsis) {
            self.viewModel.shouldShowOptionsSheet.toggle()
        }
        
        let trailingButtons = HStack {
         
            favoriteButtons
            ellipseButton
            
        }
        .asAnyView()
        
        return NavBarView(
            title: "Preview",
            leftButtonView: backButton,
            rightButtonView: trailingButtons
        )
        
    }
    
    @ViewBuilder
    private func selectedMedia() -> some View {
        
        ZStack(alignment: .top) {
            
            if let media = self.viewModel.selectedMedia {
                
                ZoomView {
                    
                    ImageSource.remote(url: media.url)
                        .view()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .frame(width: UIScreen.main.bounds.width)
                    
                }
                .id(media.id)
                .frame(width: UIScreen.main.bounds.width)
                
            }
            
            mediaTagsList()
            
        }
        
    }
    
    @ViewBuilder
    private func mediaList() -> some View {
        
        ScrollViewReader { proxy in
            
            ScrollView(.horizontal) {
                
                HStack(spacing: Style.shared.spacing(.custom(2))) {
                    
                    ForEach(self.viewModel.media, id: \.id) { media in
                        
                        let isSelected = (self.viewModel.selectedMedia == media)
                        
                        ImageSource.remote(url: media.url)
                            .view()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 65, height: 65)
                            .clipped()
                            .appBorder(
                                cornerRadius: .small,
                                color: .color(isSelected ? GPColor.green : .clear),
                                lineWidth: 3,
                                outerBorder: false
                            )
                            .cornerRadius(.custom(9))
                            .appOnTapGesture {
                                
                                self.viewModel
                                    .select(media: media)
                                
                            }
                        
                    }
                    
                }
                .scrollTargetLayout()
                
            }
            .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
            .scrollTargetBehavior(.viewAligned(limitBehavior: .never))
            .padding(.top, .medium)
            .background(Style.shared.background(.quaternary).source())
            .ignoresSafeArea()
            .onAppear {
                
                withAnimation(.bouncy) {
                    proxy.scrollTo(self.viewModel.selectedMediaId, anchor: .center)
                }
                
            }
            .onChange(of: self.viewModel.selectedMediaId) { _, newValue in
                
                withAnimation(.bouncy) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func optionsSheet() -> some View {
        
        let tagsTitle = self.viewModel.shouldShowTags ? "Hide Tags" : "Show Tags"
        let tagIcon = self.viewModel.shouldShowTags ? "tag.slash.fill" : "tag.fill"
        
        VStack(spacing: Style.shared.spacing(.none)) {
            
            // Show Tags
            
            lineItem(
                title: tagsTitle,
                icon: tagIcon,
                tintColor: Style.shared.accent.source()
            )
            .appOnTapGesture {
                
                self.viewModel
                    .shouldShowTags.toggle()
                
            }
            
            // Update Tags
            
            lineItem(
                title: "Edit Tags",
                icon: "pencil",
                tintColor: Style.shared.accent.source()
            )
            .appOnTapGesture {
                
                self.viewModel
                    .showMediaTagSheet()
                
            }
            
            // Delete
            
            lineItem(
                title: "Delete Media",
                icon: "trash.fill",
                tintColor: Style.shared.background(.error).source()
            )
            .appOnTapGesture {
                
                self.viewModel
                    .presentDeleteMediaAlert()
                
            }
            
        }
        .padding(.top, .large)
        
    }
    
    private func lineItem(title: String,
                  icon: String,
                  tintColor: AnyShapeStyle) -> some View {
        
        HStack {
            
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundStyle(tintColor)
            
            Text(title)
                .appFont(with: .TITLE_4)
                .foregroundStyle(Style.shared.textColor(.title).source())
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundStyle(Style.shared.textColor(.body).source())
            
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .medium)
        .background(.backgroundTappable)
        .animation(.smooth, value: self.viewModel.selectedMedia)
        .contentTransition(.numericText())
        
    }
    
    @ViewBuilder
    private func mediaTagsList() -> some View {
        
        let tags = self.viewModel.selectedMedia?.tags ?? []
        
        if self.viewModel.selectedMedia != nil,
           self.viewModel.shouldShowTags {
            
            ScrollView(.horizontal) {
                
                HStack {
                    
                    ForEach(tags, id: \.id) { tag in
                        mediaTag(tag)
                    }
                    
                    if tags.isEmpty {
                        mediaTag(.init(id: "edit", name: "Add Tags"))
                    }
                    
                }
                
            }
            .scrollIndicators(.hidden)
            .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
            .id(self.viewModel.selectedMediaId)
            .animation(.spring, value: self.viewModel.selectedMediaId)
            .transition(.move(edge: .leading).combined(with: .opacity))
            
        }
        
    }
    
    private func mediaTag(_ mediaTag: MediaTag) -> some View {
        
        let isEditTag = (mediaTag.id == "edit")
        
        return TokenView(
            text: mediaTag.name,
            foregroundStyle: isEditTag ? Style.shared.textColor(.button) : Style.shared.textColor(.title),
            backgroundStyle: isEditTag ? Style.shared.accent : .color(.clear),
            verticalPadding: .extraSmall,
            clipShape: .init(.rect(cornerRadius: Style.shared.radius(.extraSmall)))
        )
        .appBorder(
            cornerRadius: .extraSmall,
            color: isEditTag ? Style.shared.accent : Style.shared.background(.border),
            lineWidth: 1.5
        )
        .appShadow(.subtle)
        .asButton {
        
            self.viewModel
                .showMediaTagSheet()
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(MediaPreviewViewModel.self)
        .setup(
            selectedMedia: MockModels.MockMedia.media13,
            media: MockModels.allMedia
    )
    
    MediaPreviewScreen(viewModel: viewModel)
        .withMockServices()
    
}
