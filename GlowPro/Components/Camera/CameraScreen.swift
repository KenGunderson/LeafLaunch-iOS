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
    
    public var body: some View {
        
        content()
        
        // Safe Area
        
        .safeAreaInset(edge: .top) {
            topBarView()
        }
        .safeAreaInset(edge: .bottom) {
            bottomBarView()
        }
        
        // Lifecycle
        
        .onAppear {
            viewModel.setup()
        }
        .onDisappear {
            viewModel.teardown()
        }
        
    }
    
    @ViewBuilder
    private func content() -> some View {
        
        ZStack {
            
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                errorMessage()
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func topBarView() -> some View {
        
        HStack {
            
            if let img = viewModel.captureMode.latestPhoto {
                
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 104)
                    .clipShape(RoundedRectangle(cornerRadius: Style.shared.radius(.small), style: .continuous))
                    .overlay(
                        
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(.white.opacity(0.8), lineWidth: 1)
                        
                    )
                    .shadow(radius: 6)
                
            }
            
            Spacer()
            
            CircularIconView(
                foregroundColor: .color(.white),
                backgroundColor: .material(.ultraThinMaterial),
                imageSource: .systemImage("xmark"),
                size: 36
            )
            
        }
        .padding(.top, .medium)
        .padding(.horizontal, .medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func bottomBarView() -> some View {
        
        ShutterButton(disabled: viewModel.isShutterDisabled) {
            viewModel.shutter()
        }
        .centerHorizontally()
        .padding(.bottom, .large)
        
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
