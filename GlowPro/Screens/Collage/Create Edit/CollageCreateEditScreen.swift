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
    
    @State private var uiImageToSave: UIImage?
    @State private var collageView: AnyView?
    
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
        
        // On Change
        
            .onChange(of: self.uiImageToSave) { oldValue, newValue in
                
                guard let image = newValue else { return }
                self.viewModel.save(image: image)
                
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
        
        return NavBarView(
            title: self.viewModel.navTitle,
            leftButtonView: backButton,
        )
        
    }
    
    private func content() -> some View {
        
        AppHeaderScrollView(horizontalPadding: .none) {
            navBar()
        } scrollViewContent: {
            
            buildCollageView(
                collage: self.viewModel.selectedCollageType
            )
            
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
    }
    
    private func buildCollageView(collage: CollageType) -> some View {
        
        return collageItem(
            collageType: collage,
            useBorderAccent: false,
            height: self.collageWidth
        ) { index in
            
            self.viewModel
                .pushMediaSelection(index: index)
            
        }
        .padding(.horizontal, .medium)
        .transition(.opacity)
        .id(collage.hashValue)
        .animation(.spring, value: self.viewModel.selectedCollageType)
        .asAnyView()
                
    }
    
    @ViewBuilder
    private func collageOptionsList() -> some View {
            
        ScrollView(.horizontal) {
            
            HStack(spacing: Style.shared.spacing(.small)) {
                
                ForEach(CollageCreateEditViewModel.CollageTypeOptions.allCases, id: \.self) { option in
                    
                    collageItem(
                        collageType: option.collageType,
                        useBorderAccent: true,
                        height: 90,
                        action: nil
                    )
                    .asButton {

                        self.viewModel
                            .set(collageType: option.collageType)
                        
                    }
                    
                }
                
            }
            
        }
        .scrollIndicators(.hidden)
        
    }
    
    @ViewBuilder
    private func collageItem(collageType: CollageType,
                             useBorderAccent: Bool,
                             height: CGFloat,
                             cornerRadius: Theme.RadiusKey = .small,
                             action: ((Int) -> ())? = nil) -> some View {
        
        let urls = self.viewModel.selectedMediaURLs.map({ $0?.media?.url })
        let isSelected = self.viewModel.selectedCollageType == collageType
        
        var borderColor: ColorSource {
            
            if !useBorderAccent || !isSelected {
                return Style.shared.background(.border)
            }
            
            return Style.shared.accent
            
        }
        
        CollageView(
            items: urls,
            type: collageType,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            height: height,
            borderLineWidth: 2.5,
            action: action
        )
        .frame(width: height)
        
    }
    
    private func saveButton() -> some View {
        
        CommonButton(
            title: self.viewModel.saveButtonTitle,
            isEnabled: self.viewModel.isSaveButtonEnabled) {
                
                saveButtonTapped()
                
            }
        
    }
    
    @ViewBuilder
    private func bottomBar() -> some View {
        
        VStack(spacing: Style.shared.spacing(.small)) {
            
            collageOptionsList()
                .safeAreaPadding(.horizontal, Style.shared.spacing(.medium))
            
            saveButton()
                .padding(.horizontal, .medium)
            
        }
        .background(Style.shared.background(.primary).source())
        
    }
    
    private func saveButtonTapped() {
        
        let view = collageItem(
            collageType: self.viewModel.selectedCollageType,
            useBorderAccent: false,
            height: self.collageWidth,
            cornerRadius: .none
        )
            .background(.clear)
                
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        renderer.proposedSize = .init(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.width
        )
        renderer.isOpaque = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.uiImageToSave = renderer.uiImage
        }
        
    }
    
}

#Preview {
        
    let viewModel = mockResolve(CollageCreateEditViewModel.self)
        .setup(
            clientId: MockModels.ID.client1,
            collageId: nil
        )
    
    CollageCreateEditScreen(viewModel: viewModel)
        .withMockServices()
    
}
