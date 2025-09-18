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
        
        let trashButton = NavBarButton(style: .trash) {
        
            self.viewModel
                .delete()
            
        }
        .asAnyView()
        
        return NavBarView(
            title: "Review Media",
            leftButtonView: backButton,
            rightButtonView: trashButton
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
                
                HStack(spacing: Style.shared.spacing(.custom(2))) {
                    
                    ForEach(self.viewModel.images, id: \.id) { image in
                        
                        if let uiImage = image.kind.image {
                            
                            let isSelected = (self.viewModel.selectedImage == image)
                            
                            ImageSource
                                .uiImage(uiImage, renderingMode: .original)
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
                                        .select(image: image)
                                    
                                }
                                .transition(.asymmetric(
                                    insertion: .opacity,
                                    removal: .scale.combined(with: .opacity)
                                ))
                            
                        }
                        
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
            .animation(.snappy, value: self.viewModel.selectedImage)
            
        }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if !self.hideBottomBar {
            
            VStack(spacing: Style.shared.spacing(.small2)) {
                
                if !self.viewModel.isSingleMedia {
                    mediaList()
                }
                
                CommonButton(title: "Save Media (\(self.viewModel.images.count))") {
                    
                }
                .padding(.horizontal, .medium)
                
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.snappy, value: self.viewModel.selectedImage)
            
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
            ]
        )
    
    MediaReviewScreen(viewModel: viewModel)
        .withMockServices()
    
}
