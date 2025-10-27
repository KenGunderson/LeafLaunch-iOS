//
//  MediaSourceSelectionView.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/16/25.
//

import SwiftUI

enum SourceType: String, CaseIterable {
    
    case camera
    case gallery
    case applePhotos
    
    var displayName: String {
        switch self {
        case .camera: return "Camera"
        case .gallery: return "Media Gallery"
        case .applePhotos: return "Apple Gallery"
        }
    }
    
    var image: ImageSource {
        switch self {
        case .camera: return .image(.iconCamera)
        case .gallery: return .image(.iconAlbum)
        case .applePhotos: return .systemImage("photo")
        }
    }
    
}

struct MediaSourceSelectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let sourceTypes: [SourceType]
    private let selectedSourceTypeAction: (SourceType) -> Void
    
    init(sourceTypes: [SourceType] = [.camera, .gallery, .applePhotos],
         selectedSourceTypeAction: @escaping (SourceType) -> Void) {
        
        self.sourceTypes = sourceTypes
        self.selectedSourceTypeAction = selectedSourceTypeAction
        
    }
    
    var body: some View {
        
        VStack(spacing: Style.shared.spacing(.small2)) {
            
            ForEach(self.sourceTypes, id: \.rawValue) { source in
                sourceItemView(source)
            }
            
        }
        .padding(.horizontal, .medium)
        .padding(.vertical, .large)
        .background(Style.shared.background(.primary).source())
        
    }
    
    @ViewBuilder
    private func sourceItemView(_ sourceType: SourceType) -> some View {
        
        AppCardView(shadow: .subtle) {
            
            HStack(spacing: Style.shared.spacing(.small)) {
                
                sourceType
                    .image
                    .view()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Style.shared.accent.source())
                
                Text(sourceType.displayName)
                    .appFont(with: .TITLE_4)
                    .foregroundStyle(Style.shared.textColor(.title).source())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
        }
        .asButton {
            
            selectedSourceTypeAction(sourceType)
            dismiss()
            
        }
        
    }
    
}

#Preview {
    
    MediaSourceSelectionView { source in
        print(source.displayName)
    }
    
}
