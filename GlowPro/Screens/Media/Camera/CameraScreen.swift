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
    
    @State private var showBottomOverlayDrawer: Bool = true
    @State private var selectedGhostOverlayCategory: GhostOverlayCategory? = .grid
    @State private var selectedGhostOverlayItem: GhostOverlayView.GhostOverlayItem?
    @State private var zoomScale: CGFloat = 1.0
    
    public var body: some View {
        
        content()
        
        // Lifecycle
        
        .onAppear {
            viewModel.setup()
        }
        
        // Animations
        
        .animation(.snappy, value: self.showBottomOverlayDrawer)
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        ZStack(alignment: .center) {
            
            if ProcessInfo.isPreview || ProcessInfo.isSimulator {
                
                Color.indigo
                    .opacity(0.50)
                    .ignoresSafeArea()
                
            }
            
            CameraPreviewView(session: viewModel.session)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .onTapGesture {
                    self.showBottomOverlayDrawer = false
                }
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            
                            self.viewModel.zoom(scale: value / self.zoomScale)
                            self.zoomScale = value
                            
                        }
                        .onEnded { _ in
                            self.zoomScale = self.viewModel.zoomFactor
                        }
                )
                
            topBarView()
            selectedOverlay()
            bottomOverlay()
            
        }
        
    }
    
    @ViewBuilder
    private func topBarView() -> some View {
        
        VStack {
            
            HStack {
                
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
                
                CircularIconView(
                    foregroundColor: .color(.white),
                    backgroundColor: .material(.ultraThinMaterial),
                    imageSource: .systemImage("person.crop.square.on.square.angled"),
                    size: 40
                )
                .asButton {
                    
                    self.showBottomOverlayDrawer.toggle()
                    
                }
                
                Spacer()
                
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
            .padding(.top, .medium)
            .padding(.horizontal, .medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(.spring, value: self.viewModel.cameraFlashMode)
            
            Spacer()
            
        }
        
    }
    
    @ViewBuilder
    private func bottomBarView() -> some View {
        
        HStack {
            
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
        .padding(.horizontal, .medium2)
        .frame(height: 80)
        .frame(maxWidth: .infinity, alignment: .leading)
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
                
                let backgroundColor = Style.shared.background(.primary)
                
                bottomBarView()
                
                if self.showBottomOverlayDrawer {
                    
                    VStack(spacing: -0.5) {
                        
                        VStack {
                            
                            GhostOverlayView(
                                selectedGhostOverlayItem: self.$selectedGhostOverlayItem,
                                images: .constant(selectedGhostOverlayCategory?.images ?? [])
                            )
                            .padding(.bottom, .small)
                            
                            GhostOverlayCarouselView(selectedGhostOverlayCategory: self.$selectedGhostOverlayCategory)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .background(backgroundColor.source())
                        .clipShape(.rect(cornerRadii: .init(
                            topLeading: Style.shared.radius(.small2),
                            topTrailing: Style.shared.radius(.small2))
                        ))
                        
                        backgroundColor
                            .view()
                            .ignoresSafeArea()
                        
                    }
                    .compositingGroup()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
 
                }
                
            }
            .fixedSize(horizontal: false, vertical: true)
            
        }
        .animation(.snappy, value: self.selectedGhostOverlayItem)
        
    }
    
    @ViewBuilder
    private func selectedOverlay() -> some View {
     
        if let selectedGhostOverlayItem {
            
            let normalized = selectedGhostOverlayItem.scale - 0.5   // -0.5...+0.5
            let factor = pow(2.0, normalized * 3)
            
            selectedGhostOverlayItem
                .image
                .view(renderingMode: .original)
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
    
}

#Preview {
    
    let viewModel = mockResolve(CameraViewModel.self)
    
    CameraScreen(viewModel: viewModel)
        .withMockServices()
    
}
