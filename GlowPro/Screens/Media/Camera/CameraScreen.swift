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
    
    @State private var showTopOverlayDrawer: Bool = false
    @State private var showBottomOverlayDrawer: Bool = true
    
    @State private var selectedGhostOverlayItem: GhostOverlayView.GhostOverlayItem?
    
    public var body: some View {
        
        content()
        
        // Lifecycle
        
        .onAppear {
            viewModel.setup()
        }
        
        // Animations
        
        .animation(.snappy, value: self.showTopOverlayDrawer)
        .animation(.snappy, value: self.showBottomOverlayDrawer)
        .animation(.snappy, value: self.selectedGhostOverlayItem)
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        ZStack(alignment: .center) {
            
            CameraPreviewView(session: viewModel.session)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
                .onTapGesture {
                    
                    self.showBottomOverlayDrawer = false
                    self.showTopOverlayDrawer = false
                    
                }
            
            selectedOverlay()
            topOverlay()
            bottomOverlay()
            
        }
        
    }
    
    @ViewBuilder
    private func topBarView() -> some View {
        
        HStack {
            
            CircularIconView(
                foregroundColor: .color(.white),
                backgroundColor: .material(.ultraThinMaterial),
                imageSource: .systemImage("slider.horizontal.below.sun.max"),
                size: 36
            )
            .asButton {
                
                self.showTopOverlayDrawer.toggle()
                
            }
            
            CircularIconView(
                foregroundColor: .color(.white),
                backgroundColor: .material(.ultraThinMaterial),
                imageSource: .systemImage("slider.horizontal.below.rectangle"),
                size: 36
            )
            .asButton {
                
                self.showBottomOverlayDrawer.toggle()
                
            }
            
            Spacer()
            
            CircularIconView(
                foregroundColor: .color(.white),
                backgroundColor: .material(.ultraThinMaterial),
                imageSource: .systemImage("xmark"),
                size: 36
            )
            .asButton {
                
                self.viewModel.teardown()
                dismiss()
                
            }
            
        }
        .padding(.top, .medium)
        .padding(.horizontal, .medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        
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
    private func topOverlay() -> some View {
        
        VStack {
        
            ZStack(alignment: .top) {
                
                topBarView()
                
                if self.showTopOverlayDrawer {
                    
                    Rectangle()
                        .fill(Style.shared.background(.quaternary).source())
                        .frame(height: 350)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .ignoresSafeArea()
                    
                }
                
            }
            .background(.backgroundTappable)
            
            Spacer()
            
        }
        .frame(maxHeight: .infinity)
        
    }
    
    @ViewBuilder
    private func bottomOverlay() -> some View {
        
        VStack {
            
            Spacer()
            
            ZStack(alignment: .bottom) {
                
                bottomBarView()
                
                if self.showBottomOverlayDrawer {
                    
                    VStack {

                        GhostOverlayView(selectedGhostOverlayItem: self.$selectedGhostOverlayItem)
                            .padding(.bottom, .small)
                        
                    }
                    .frame(maxWidth: .infinity)
                    .background(Style.shared.background(.quaternary).source())
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                }
                
            }
            .background(.backgroundTappable)
            
        }
        
    }
    
    @ViewBuilder
    private func selectedOverlay() -> some View {
     
        if let selectedGhostOverlayItem {
            
            let normalized = selectedGhostOverlayItem.scale - 0.5   // -0.5...+0.5
            let factor = pow(2.0, normalized * 3)
            
            selectedGhostOverlayItem
                .image
                .view()
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
                    self.showBottomOverlayDrawer = true
                }
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(CameraViewModel.self)
    
    CameraScreen(viewModel: viewModel)
        .withMockServices()
    
}
