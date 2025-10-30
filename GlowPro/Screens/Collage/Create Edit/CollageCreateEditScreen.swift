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
    
    @State private var uiImageToSave: UIImage?
    @State private var collageView: AnyView?
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    var collageWidth: CGFloat {
        
        let screen = UIScreen.main.bounds
        let inset: CGFloat = 32
        let verticalInsets: CGFloat = (88 + 90 + 16 + 32 + 44 + 16 + 32)
        
        switch self.orientation {
        case .portrait, .portraitUpsideDown: return screen.width - inset
        case .landscapeLeft, .landscapeRight: return screen.height - inset - verticalInsets
        default: return screen.width - inset
        }
        
    }
        
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
        
            .detectRotation { orientation in
                self.orientation = orientation
            }
        
        // Animations
        
            .animation(.smooth, value: self.viewModel.selectedCollageType)
            .animation(.smooth, value: self.viewModel.selectedMediaURLs)
            .animation(.smooth, value: self.viewModel.selectedCollageContentMode)
        
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
            
            VStack(spacing: Style.shared.spacing(.small)) {
                
                buildCollageView(
                    collage: self.viewModel.selectedCollageType
                )
                
                segmentedControlView()
                colorPickerView()
                
            }
            
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
    
    private func segmentedControlView() -> some View {
        
        CommonSegmentedControl(
            selectedOption: self.$viewModel.selectedCollageContentMode,
            options: CollageCreateEditViewModel.CollageContentMode.allCases,
            selectedTextColor: Style.shared.textColor(.titleInverted)
        )
        .frame(maxWidth: 360)
        .padding(.horizontal, .medium)
        
    }
    
    private func colorPickerView() -> some View {
        
        HStack(spacing: Style.shared.spacing(.small)) {
            
            Text("Background Color:")
                .foregroundStyle(Style.shared.textColor(.title).source())
                .appFont(with: .TITLE_4)
            
            ColorPicker("", selection: self.$viewModel.selectedBackgroundColor)
                .fixedSize(horizontal: true, vertical: false)
            
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
            backgroundColor: .color(self.viewModel.selectedBackgroundColor),
            scaleToFill: self.viewModel.selectedCollageContentMode == .fill,
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
