//
//  CameraScreen.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/30/25.
//
    
import SwiftUI
import AVFoundation
import Photos

public struct CameraScreen: View {
        
    @Environment(\.dismiss) private var dismiss
    @Environment(NavigationService.self) private var navigationService
    
    @StateObject var viewModel: CameraViewModel
    
    @State private var showBottomOverlayDrawer: Bool = false
    @State private var selectedGhostOverlayCategory: GhostOverlayCategory? = .head
    @State private var selectedGhostOverlayItem: GhostOverlayView.GhostOverlayItem?
    @State private var zoomScale: Double = 1.0
    @State private var gridDivision: Int = 0
    
    public var body: some View {
        
        content()
        
        // Lifecycle
        
        .onAppear {
            viewModel.setup()
        }
        
        // On Change
        
        .onChange(of: self.zoomScale) { oldValue, newValue in
            
            self.viewModel
                .zoom(scale: newValue)
            
        }
        
        .onChange(of: self.selectedGhostOverlayItem) { oldValue, newValue in
            
            guard newValue?.id == "CUSTOM" else { return }
            
            let isOldValyeASystemImage = oldValue?.image.isSystemImage ?? false
            let isNewValueARemoteImage = newValue?.image.isRemote ?? false
            
            if isOldValyeASystemImage && isNewValueARemoteImage {
                
                // We return since we already selected the custom image
                return
                
            }
            
            if !isNewValueARemoteImage {
                handleCustomMediaGallerySelection()
            }
            
        }
        
        // Animations
        
        .animation(.snappy, value: self.showBottomOverlayDrawer)
        .animation(.snappy, value: self.zoomScale)
        .animation(.snappy, value: self.gridDivision)
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        ZStack(alignment: .center) {
            
            CameraPreviewView(session: viewModel.session)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .onTapGesture {
                    self.showBottomOverlayDrawer = false
                }
                
            topBarView()
            gridOverlay()
            selectedOverlay()
            zoomSlider()
            bottomOverlay()
            
        }
        
    }
    
    @ViewBuilder
    private func topBarView() -> some View {
        
        HStack {
            
            flashButton()
            autoFlashButton()
            
            closeButton()
                .frame(maxWidth: .infinity, alignment: .trailing)
            
        }
        .padding(.top, .medium)
        .padding(.horizontal, .medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.spring, value: self.viewModel.cameraFlashMode)
        .frame(maxHeight: .infinity, alignment: .top)
        
    }
    
    @ViewBuilder
    private func bottomBarView() -> some View {
                
        HStack {
            
            latestPhoto()
            
            gridButton()
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            ghostOverlayButton()
            
        }
        .padding(.horizontal, .medium2)
        .frame(height: 80)
        .overlay {
            
            ShutterButton(disabled: viewModel.isShutterDisabled) {
                viewModel.shutter()
            }
            
        }
        
    }
    
    @ViewBuilder
    private func bottomOverlay() -> some View {
        
        VStack {
            
            Spacer()
            
            ZStack(alignment: .bottom) {
                
                bottomBarView()
                bottomDrawerContent()
                
            }
            .fixedSize(horizontal: false, vertical: true)
            
        }
        .animation(.snappy, value: self.selectedGhostOverlayItem)
        
    }
    
    @ViewBuilder
    private func gridOverlay() -> some View {
        
        if self.gridDivision > 0 {
            
            GridOverlay(
                divisions: self.gridDivision,
                lineWidth: 2,
                inset: 24
            )
            .transition(.opacity)
            
        }
        
    }
    
    @ViewBuilder
    private func flashButton() -> some View {
     
        let isAutoFlashMode = (self.viewModel.cameraFlashMode == .auto)
        let isFlastOn = (self.viewModel.cameraFlashMode == .on)
        let onColor = GPColor.iconYellow
        let offColor: Color = .white
        
        let flashIcon = isAutoFlashMode
            ? CameraFlashMode.off.icon
            : viewModel.cameraFlashMode.icon
        
        CircularIconView(
            foregroundColor: .color(isFlastOn ? onColor : offColor),
            backgroundColor: .material(.ultraThinMaterial),
            imageSource: .systemImage(flashIcon),
            size: 40
        )
        .asButton {
            
            self.viewModel
                .toggleFlash()
            
        }
        .contentTransition(.symbolEffect(.replace))
        
    }
    
    @ViewBuilder
    private func autoFlashButton() -> some View {
     
        let isAutoFlashMode = (self.viewModel.cameraFlashMode == .auto)
        let onColor = GPColor.iconYellow
        let offColor: Color = .white
        
        CircularIconView(
            foregroundColor: .color(isAutoFlashMode ? onColor : offColor),
            backgroundColor: .material(.ultraThinMaterial),
            imageSource: .systemImage(CameraFlashMode.auto.icon),
            size: 40
        )
        .asButton {
            
            self.viewModel
                .setCameraFlashMode(.auto)
            
        }
        .contentTransition(.symbolEffect(.replace))
        
    }
    
    @ViewBuilder
    private func closeButton() -> some View {
        
        CircularIconView(
            foregroundColor: .color(.white),
            backgroundColor: .material(.ultraThinMaterial),
            imageSource: .systemImage("xmark"),
            size: 40
        )
        .asButton {
            
            self.viewModel.teardown()
            dismiss()
            
        }
        
    }
    
    @ViewBuilder
    private func gridButton() -> some View {
        
        let isGridEnabled = self.gridDivision > 0
        
        CircularIconView(
            foregroundColor: isGridEnabled ? Style.shared.accent : .color(.white),
            backgroundColor: .material(.ultraThinMaterial),
            imageSource: .systemImage("grid"),
            size: 48
        )
        .asButton {
            
            var nextGridDivision: Int {
                
                if self.gridDivision == 0 {
                    return 3
                }
                
                if self.gridDivision == 5 {
                    return 0
                }
                
                return self.gridDivision + 1
                
            }
            
            self.gridDivision = nextGridDivision

        }
        
    }
    
    @ViewBuilder
    private func ghostOverlayButton() -> some View {
        
        CircularIconView(
            foregroundColor: .color(.white),
            backgroundColor: .material(.ultraThinMaterial),
            imageSource: .systemImage("person.crop.square.on.square.angled"),
            size: 48
        )
        .asButton {
            
            self.showBottomOverlayDrawer.toggle()
            
        }
        
    }
    
    @ViewBuilder
    private func latestPhoto() -> some View {
        
        if let image = viewModel.captureMode.latestPhoto {
            
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 65, height: 65)
                .clipShape(RoundedRectangle(
                    cornerRadius: Style.shared.radius(.small),
                    style: .continuous
                ))
                .overlay(
                    
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(.white.opacity(0.8), lineWidth: 2)
                    
                )
                .shadow(radius: 6)
                .asButton {
                    
                    self.navigationService
                        .push(.media(.review(
                            context: .transformFromMediaContext(self.viewModel.context),
                            images: self.viewModel.allImages
                        )))
                    
                }
            
        }
        
    }
    
    @ViewBuilder
    private func selectedOverlay() -> some View {
     
        if let selectedGhostOverlayItem {
            
            let normalized = selectedGhostOverlayItem.scale - 0.5   // -0.5...+0.5
            let factor = pow(2.0, normalized * 3)
            
            selectedGhostOverlayItem
                .image
                .view(renderingMode: .template)
                .foregroundStyle(.white)
                .aspectRatio(contentMode: .fit)
                .frame(
                    width: UIScreen.main.bounds.width * 0.85
                )
                .clipped()
                .cornerRadius(.none)
                .foregroundStyle(.white)
                .scaleEffect(factor)
                .opacity(selectedGhostOverlayItem.opacity)
                .padding(.bottom, 44)
                .background(.backgroundTappable)
                .appOnTapGesture {
                    self.showBottomOverlayDrawer.toggle()
                }
            
        }
        
    }
    
    @ViewBuilder
    private func zoomSlider() -> some View {
        
        HStack {
         
            Spacer()
            
            HStack(spacing: 0) {
                
                CircularIconView(
                    foregroundColor: .color(.white),
                    backgroundColor: .color(.clear),
                    imageSource: .systemImage("minus.magnifyingglass"),
                    size: 40
                )
                .rotationEffect(.degrees(90))
                
                ProgressSliderTicker(
                    value: self.$zoomScale,
                    range: 1...3,
                    step: 0.25,
                    trackStyle: .material(.ultraThin),
                    ticksStyle: .material(.thin),
                    thumbStyle: Style.shared.accent,
                    thumbDotStyle: Style.shared.textColor(.button),
                    thumbCornerRadius: 99,
                    trackFillCornerRadius: 99,
                    tickerStyle: .line(lineWidth: 1.5),
                )
                .frame(
                    width: 200,
                    height: 32
                )
                
                CircularIconView(
                    foregroundColor: .color(.white),
                    backgroundColor: .color(.clear),
                    imageSource: .systemImage("plus.magnifyingglass"),
                    size: 40
                )
                .rotationEffect(.degrees(90))
                
            }
            .rotationEffect(.degrees(-90))
            .offset(x: 200 / 1.85)
            
        }
        .offset(y: 128)
        
    }
    
    @ViewBuilder
    private func bottomDrawerContent() -> some View {
        
        let backgroundColor = Style.shared.background(.primary)
        
        if self.showBottomOverlayDrawer {
            
            VStack(spacing: -0.5) {
                
                VStack(spacing: 0) {
                    
                    NavBarButton(style: .close) {
                        self.showBottomOverlayDrawer = false
                    }
                    .padding([.top, .horizontal], .medium)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    GhostOverlayView(
                        selectedGhostOverlayItem: self.$selectedGhostOverlayItem,
                        images: .constant(selectedGhostOverlayCategory?.images ?? [])
                    )
                    .padding(.bottom, .small)
                    
                    GhostOverlayCarouselView(selectedGhostOverlayCategory: self.$selectedGhostOverlayCategory)
                        .padding(.top, .small)
                    
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .background(backgroundColor.source())
                .clipShape(.rect(cornerRadii: .init(
                    topLeading: Style.shared.radius(.large),
                    topTrailing: Style.shared.radius(.large))
                ))
                
                backgroundColor
                    .view()
                    .ignoresSafeArea()
                
            }
            .compositingGroup()
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onEnded({ value in
                    
                    if value.translation.height > 50 {
                        self.showBottomOverlayDrawer = false
                    }
                    
                }))
            
        }
        
    }
    
    private func handleCustomMediaGallerySelection() {
        
        self.navigationService
            .push(.media(.gallery(
                mediaContext: self.viewModel.context,
                mediaSelectionContext: .singleSelection(completion: { selectedMedia in
                    
                    if let url = selectedMedia?.url {
                        
                        self.selectedGhostOverlayItem = .init(
                            id: "CUSTOM",
                            image: .remote(url: url)
                        )
                        
                    }
                    
                })
                
            )))
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(CameraViewModel.self)
    
    CameraScreen(viewModel: viewModel)
        .withMockServices()
    
}
