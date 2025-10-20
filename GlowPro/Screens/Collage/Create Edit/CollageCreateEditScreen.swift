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
            
            buildCollageView(
                collage: self.viewModel.selectedCollageType
            )
            
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar()
        }
        
    }
    
    @ViewBuilder
    private func buildCollageView(collage: CollageType) -> some View {
        
        collageItem(
            collageType: collage,
            useBorderAccent: false,
            height: self.collageWidth
        ) { index in
            
            self.viewModel
                .pushMediaSelection(index: index)
            
        }
        .padding(.horizontal, .medium)
        
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
            .scrollTargetLayout()
            
        }
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .scrollIndicators(.hidden)
        
    }
    
    @ViewBuilder
    private func collageItem(collageType: CollageType,
                             useBorderAccent: Bool,
                             height: CGFloat,
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
                
                self.viewModel
                    .saveOrUpdate()
                
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
