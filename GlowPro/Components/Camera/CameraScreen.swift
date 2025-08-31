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
        
        ZStack {
            
            CameraPreviewView(session: viewModel.session)
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.bottom, 8)
                }
                
                HStack {
                    Spacer()
                    ShutterButton(disabled: viewModel.isShutterDisabled) {
                        viewModel.shutter()
                    }
                    Spacer()
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear { viewModel.setup() }
        .onDisappear { viewModel.teardown() }
        .overlay(alignment: .topTrailing) {
            if let img = viewModel.captureMode.latestPhoto {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(.white.opacity(0.8), lineWidth: 1)
                    )
                    .padding(.top, 18)
                    .padding(.trailing, 18)
                    .shadow(radius: 6)
            }
        }
    }
}

#Preview {
    
    let viewModel = mockResolve(CameraViewModel.self)
    
    CameraScreen(viewModel: viewModel)
        .withMockServices()
    
}
