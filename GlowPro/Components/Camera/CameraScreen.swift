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
    @StateObject var viewModel: CameraViewModel
    
    @State private var showTopOverlayDrawer: Bool = false
    @State private var showBottomOverlayDrawer: Bool = false
    
    public var body: some View {
        
        content()
        
        // Safe Area
        
        .safeAreaInset(edge: .top) {
            
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
            
        }
        .safeAreaInset(edge: .bottom) {
            
            ZStack(alignment: .bottom) {
                
                bottomBarView()
                
                if self.showBottomOverlayDrawer {
                    
                    VStack {
//                        Text("123")
                    }
                    .frame(height: 350)
                    .frame(maxWidth: .infinity)
                    .background(Style.shared.background(.quaternary).source())
                    .ignoresSafeArea()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                }
                
            }
            
        }
        
        // Lifecycle
        
        .onAppear {
            viewModel.setup()
        }
        .onDisappear {
            viewModel.teardown()
        }
        
        // Animations
        
        .animation(.snappy, value: self.showTopOverlayDrawer)
        .animation(.snappy, value: self.showBottomOverlayDrawer)
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        ZStack {
            
            if ProcessInfo.isPreview || ProcessInfo.isSimulator {
                
                Color.black
                    .ignoresSafeArea()
                
            }
            
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                errorMessage()
                
            }
            
        }
        .onTapGesture {
            
            self.showBottomOverlayDrawer = false
            self.showTopOverlayDrawer = false
            
        }
        
    }
    
    @ViewBuilder
    private func topBarView() -> some View {
        
        HStack {
            
            CircularIconView(
                foregroundColor: .color(.white),
                backgroundColor: .material(.ultraThinMaterial),
                imageSource: .systemImage("arrow.up"),
                size: 36
            )
            .asButton {
                
                self.showTopOverlayDrawer.toggle()
                
            }
            
            CircularIconView(
                foregroundColor: .color(.white),
                backgroundColor: .material(.ultraThinMaterial),
                imageSource: .systemImage("arrow.down"),
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
    private func errorMessage() -> some View {
        
        if let error = viewModel.errorMessage {
            
            Text(error)
                .font(.footnote)
                .foregroundStyle(.red)
                .padding(.bottom, 8)
            
        }
        
    }
    
}

#Preview {
    
    let viewModel = mockResolve(CameraViewModel.self)
    
    CameraScreen(viewModel: viewModel)
        .withMockServices()
    
}
