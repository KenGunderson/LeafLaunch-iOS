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
        
        return NavBarView(
            title: "Preview",
            leftButtonView: backButton
        )
        
    }
    
    @ViewBuilder
    private func selectedMedia() -> some View {
        
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
                            .aspectRatio(contentMode: .fit)
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
    
}

#Preview {
    
    let viewModel = mockResolve(MediaPreviewViewModel.self)
        .setup(
            selectedMedia: MockModels.MockMedia.media13,
            media: [
            MockModels.MockMedia.media1,
            MockModels.MockMedia.media2,
            MockModels.MockMedia.media3,
            MockModels.MockMedia.media4,
            MockModels.MockMedia.media4,
            MockModels.MockMedia.media5,
            MockModels.MockMedia.media6,
            MockModels.MockMedia.media7,
            MockModels.MockMedia.media8,
            MockModels.MockMedia.media9,
            MockModels.MockMedia.media11,
            MockModels.MockMedia.media12,
            MockModels.MockMedia.media13
        ]
    )
    
    MediaPreviewScreen(viewModel: viewModel)
        .withMockServices()
    
}
