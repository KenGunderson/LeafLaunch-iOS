//
//  CollageCreateEditScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/18/25.
//

import SwiftUI

struct CollageCreateEditScreen: View {
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: CollageCreateEditViewModel
    @Namespace private var animation
    
    let collageWidth: CGFloat = UIScreen.main.bounds.width - 32
        
    init(viewModel: CollageCreateEditViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        content()
        
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
        
        // Animations
        
            .animation(.smooth, value: self.viewModel.selectedCollageType)
            .animation(.smooth, value: self.viewModel.selectedMediaURLs)
        
    }
    
    private func navBar() -> some View {
        
        let backButton = NavBarButton(style: .back) {
            self.dismiss()
        }
        .asAnyView()
        
        let trashButton = NavBarButton(style: .trash) {
            
            self.viewModel
                .presentDeleteCollageAlert()
            
        }
        .asAnyView()
        
        let shouldShowTrashButton = self.viewModel.isOwnerOrManager && !self.viewModel.isCreateContext
        
        return NavBarView(
            title: self.viewModel.navTitle,
            leftButtonView: backButton,
            rightButtonView: shouldShowTrashButton ? trashButton : nil
        )
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            
            if let collage = self.viewModel.selectedCollageType {
                
                buildCollageView(collage: collage)
                    .transition(.scale.combined(with: .opacity))
                
            } else {
                
                collageOptionsList()
                    .transition(.scale.combined(with: .opacity))
                
            }
            
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
    }
    
    @ViewBuilder
    private func buildCollageView(collage: CollageType) -> some View {
     
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            HStack {
                
                CommonButton(
                    title: "Swap Collage",
                    icon: .systemImage("xmark"),
                    iconAlignment: .leading,
                    backgroundStyle: Style.shared.background(.error),
                    horizontalPadding: .extraSmall
                ) {
                    
                    self.viewModel
                        .set(collageType: nil)
                    
                }
                
                CommonButton(
                    title: "Add Photo",
                    icon: .image(.iconCamera),
                    iconAlignment: .leading,
                    horizontalPadding: .extraSmall
                ) {
                    
                    self.viewModel
                        .pushMediaSelection()
                    
                }
                
            }
            
            collageItem(
                collageType: collage,
                height: self.collageWidth
            )
            
        }
        .padding(.horizontal, .medium)
        
    }
    
    @ViewBuilder
    private func collageOptionsList() -> some View {
            
        ScrollView {
            
            VStack {
                
                ForEach(CollageCreateEditViewModel.CollageTypeOptions.allCases, id: \.self) { option in
                    
                    collageItem(
                        collageType: option.collageType,
                        height: self.collageWidth
                    )
                    .asButton {
                        
                        self.viewModel
                            .set(collageType: option.collageType)
                        
                    }
                    
                }
                
            }
            .scrollTargetLayout()
            
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
        .scrollIndicators(.hidden)
        
    }
    
    @ViewBuilder
    private func collageItem(collageType: CollageType,
                             height: CGFloat) -> some View {
        
        let urls = self.viewModel.selectedMediaURLs.compactMap({ $0.media?.url })
        
        CollageView(
            items: urls,
            type: collageType,
            height: height
        )
        .frame(width: height)
        
    }
    
    private func saveButton() -> some View {
        
        CommonButton(
            title: self.viewModel.saveButtonTitle,
            isEnabled: self.viewModel.isSaveButtonEnabled) {
                
                self.viewModel
                    .saveOrUpdate()
                
            }
        
    }
    
    @ViewBuilder
    private func mediaItem(_ mediaFusion: MediaFusion) -> some View {
        
        switch mediaFusion.kind {
            
        case .url(let url): urlItem(url: url, mediaFusion: mediaFusion)
        case .uiImage: EmptyView()
        }
        
    }
    
    private func urlItem(url: URL,
                         mediaFusion: MediaFusion) -> some View {
        
        ImageSource
            .remote(url: url, placeholder: PlaceholderView().asAnyView())
            .view()
            .frame(width: 75, height: 75)
            .background(Style.shared.background(.primary).source())
            .appBorder(
                cornerRadius: .small,
                color: Style.shared.accent,
                lineWidth: 3,
                outerBorder: false
            )
            .cornerRadius(.custom(9))
            .overlay(alignment: .topTrailing) {
                
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(AnyShapeStyle(Color.white), Style.shared.background(.error).source())
                    .asButton {
                        
                        self.viewModel
                            .deleteMediaURL(id: mediaFusion.id)
                        
                    }
                    .offset(x: 8, y: -8)
                
            }
            .asButton {
             
                self.navigationService
                    .modal(fullScreenCover: .mediaPreview(url: url))
                
            }
        
    }
    
    private func cameraItem() -> some View {
        
        Image(systemName: "camera.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Style.shared.background(.quaternary).source())
            .padding(.large)
            .frame(width: 75, height: 75)
            .background(Style.shared.background(.primary).source())
            .appBorder(
                cornerRadius: .small,
                color: Style.shared.background(.quaternary),
                lineWidth: 3,
                outerBorder: false
            )
            .cornerRadius(.custom(9))
            .background(.backgroundTappable)
            .asButton {
                
                self.viewModel
                    .pushMediaSelection()
                
            }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        if self.viewModel.selectedCollageType != nil {
            
            VStack(spacing: Style.shared.spacing(.medium)) {
                
                mediaList()
                    .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
                
                saveButton()
                    .padding(.horizontal, .medium)
                
            }
            .background(Style.shared.background(.primary).source())
            .transition(.move(edge: .bottom).combined(with: .opacity))
            
        }
        
    }
    
    private func mediaList() -> some View {
            
        ScrollView(.horizontal) {
            
            HStack {
                
                ForEach(self.viewModel.selectedMediaURLs, id: \.id) { item in
                    mediaItem(item)
                }
                
                cameraItem()
                
            }
            .padding(.top, .small)
            
        }
        .scrollIndicators(.hidden)
        
    }
    
}

#Preview {
    
    @Previewable @State var navigationService = NavigationService()
    
    let viewModel = mockResolve(CollageCreateEditViewModel.self)
        .setup(
            clientId: MockModels.ID.client1,
            collageId: nil
        )
    
    AppRootView(navigationService: $navigationService, alertService: nil) {
        
        CollageCreateEditScreen(viewModel: viewModel)
            .withMockServices()
            .environment(navigationService)
        
    }
    
}
