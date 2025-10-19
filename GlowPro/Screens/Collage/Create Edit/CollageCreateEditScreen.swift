//
//  CollageCreateEditScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/18/25.
//

import SwiftUI

// TODO: -
/// Handle create call
/// Fix UI + transitions; matched is no good
///

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
                
                collageOptionsList(height: 72, vertical: false)
                    .matchedGeometryEffect(id: "collage_list", in: self.animation)
                
                collageItem(
                    collageType: collage,
                    allowsBorder: false,
                    height: self.collageWidth
                )
                .asButton {
                    
                    self.navigationService
                        .push(.media(.gallery(mediaContext: .client(clientId: self.viewModel.clientId), mediaSelectionContext: .singleSelection(completion: { media in
                            
                            self.viewModel
                                .set(media: media)
                            
                        }))))
                    
                }
                .transition(.move(edge: .bottom).combined(with: .scale).combined(with: .opacity).animation(.bouncy.delay(0.3)))
                .padding(.top, .extraLarge)
                
            } else {
                
                collageOptionsList(
                    height: self.collageWidth,
                    vertical: true
                )
                .opacity(self.viewModel.selectedCollageType == nil ? 1 : 0)
                .matchedGeometryEffect(id: "collage_list", in: self.animation)
                
            }
            
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
    }
    
    @ViewBuilder
    private func collageOptionsList(height: CGFloat,
                                    vertical: Bool) -> some View {
            
        ScrollView(vertical ? .vertical : .horizontal) {
            
            Group {
                
                if vertical {
                    
                    VStack {
                        collageOptions(height: height)
                    }
                    
                } else {
                    
                    HStack {
                        collageOptions(height: height)
                    }
                    
                }
                
            }
            
        }
        .if(!vertical) { view in
            view.safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
        }
        .scrollIndicators(.hidden)
        
    }
    
    @ViewBuilder
    private func collageOptions(height: CGFloat) -> some View {
        
        Group {
            
            ForEach(CollageCreateEditViewModel.CollageTypeOptions.allCases, id: \.self) { option in
                
                collageItem(
                    collageType: option.collageType,
                    height: height
                )
                .asButton {
                    
                    self.viewModel
                        .set(collageType: option.collageType)
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func collageItem(collageType: CollageType,
                             allowsBorder: Bool = true,
                             height: CGFloat) -> some View {
        
        let urls = self.viewModel.mediaURLs.compactMap({ $0.media?.url })
        
        let isSelected = (self.viewModel.selectedCollageType == collageType)
        
        CollageView(
            items: urls,
            type: collageType,
            height: height
        )
        .frame(width: height)
        .if(allowsBorder) { view in
            
            view.appBorder(
                cornerRadius: isSelected ? .small : .none,
                color: isSelected ? Style.shared.accent : .color(.clear),
                lineWidth: 3,
                outerBorder: false
            )
            
        }
        
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
                        
                        // TODO: - Address this
//                        self.viewModel
//                            .deleteMediaFusion(id: mediaFusion.id)
                        
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
                
                // TODO: - remove this?
                
//                self.viewModel
//                    .shouldShowMediaSourceSelectionSheet = true
                
            }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        VStack(spacing: Style.shared.spacing(.medium)) {

            saveButton()
                .padding(.horizontal, .medium)
            
        }
        .background(Style.shared.background(.primary).source())
        
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
        
    }
    
}
