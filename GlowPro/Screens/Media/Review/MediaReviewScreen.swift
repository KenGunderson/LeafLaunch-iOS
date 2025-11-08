//
//  MediaReviewScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/17/25.
//

import SwiftUI

struct MediaReviewScreen: GPView {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @State private var hideBottomBar: Bool = false
    
    @StateObject var viewModel: MediaReviewViewModel
    
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
            bottomBar()
        }
        .onTapGesture {
            
            withAnimation(.snappy) {
                self.hideBottomBar.toggle()
            }
            
        }
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        return NavBarView(
            title: "Review Media",
            leftButtonView: backButton
        )
        
    }
    
    @ViewBuilder
    private func selectedMedia() -> some View {
        
        ZStack(alignment: .top) {
            
            if let image = self.viewModel.selectedImage,
               let selectedImage = image.kind.image {
                
                ZoomView {
                    
                    ImageSource
                        .uiImage(selectedImage, renderingMode: .original)
                        .view()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .frame(width: UIScreen.main.bounds.width)
                    
                }
                .id(image.id)
                .frame(width: UIScreen.main.bounds.width)
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func mediaList() -> some View {
        
        ScrollViewReader { proxy in
            
            ScrollView(.horizontal) {
                
                HStack(spacing: Style.shared.spacing(.small)) {
                    
                    ForEach(self.viewModel.images, id: \.id) { image in
                        mediaItem(image)
                    }
                    
                }
                .scrollTargetLayout()
                
            }
            .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
            .scrollTargetBehavior(.viewAligned(limitBehavior: .never))
            .padding(.top, .medium)
            .onAppear {
                
                withAnimation(.bouncy) {
                    proxy.scrollTo(self.viewModel.selectedImageId, anchor: .center)
                }
                
            }
            .onChange(of: self.viewModel.selectedImageId) { _, newValue in
                
                withAnimation(.bouncy) {
                    proxy.scrollTo(newValue, anchor: .center)
                }
                
            }
            .animation(.snappy, value: self.viewModel.images)
            
        }
        
    }
    
    @ViewBuilder
    private func mediaItem(_ image: MediaFusion) -> some View {
        
        if let uiImage = image.kind.image {
            
            let isSelected = (self.viewModel.selectedImage == image)
            
            ImageSource
                .uiImage(uiImage, renderingMode: .original)
                .view()
                .aspectRatio(1, contentMode: .fit)
                .background(Style.shared.background(.primary).source())
                .frame(width: 65, height: 65)
                .appBorder(
                    cornerRadius: .small,
                    color: isSelected ? Style.shared.accent : Style.shared.background(.border),
                    lineWidth: 3,
                    outerBorder: false
                )
                .cornerRadius(.custom(9))
                .appOnTapGesture {
                    
                    self.viewModel
                        .select(image: image)
                    
                }
                .overlay(alignment: .topTrailing) {
                    
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(AnyShapeStyle(Color.white), Style.shared.background(.error).source())
                        .asButton {
                            
                            self.viewModel
                                .deleteMediaFusion(image.id)
                            
                        }
                        .padding([.top, .trailing], -8)
                    
                }
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .scale.combined(with: .opacity)
                ))
            
        }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if !self.hideBottomBar {
            
            VStack(spacing: Style.shared.spacing(.small2)) {
                
                mediaList()
                
                CommonButton(title: "Save Media (\(self.viewModel.images.count))") {
                    
                    self.viewModel
                        .create()
                    
                }
                .padding(.horizontal, .medium)
                
            }
            .background(Style.shared.background(.primary).source())
            .overlay(alignment: .top) {
                
                Rectangle()
                    .fill(Style.shared.background(.quaternary).source())
                    .frame(height: 1)
                
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.snappy, value: self.viewModel.selectedImage)
            .animation(.snappy, value: self.viewModel.images)
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(MediaReviewViewModel.self)
        .setup(
            context: .client(clientId: MockModels.ID.client1),
            images: [
                .init(named: "illustration_tutorial_1")!,
                .init(named: "illustration_tutorial_2")!,
                .init(named: "illustration_tutorial_3")!
            ]) { _ in
                
            }
    
    MediaReviewScreen(viewModel: viewModel)
        .withMockServices()
    
}
