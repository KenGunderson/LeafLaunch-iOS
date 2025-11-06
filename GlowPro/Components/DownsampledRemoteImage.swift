//
//  DownsampledRemoteImage.swift
//  GlowPro
//
//  Created by AI on 11/6/25.
//

import SwiftUI
import ImageIO

final class DownsampledImageCache {
    
    static let shared = DownsampledImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private init() {
        
        // Reasonable upper bound; adjust if needed
        self.cache.totalCostLimit = 150 * 1024 * 1024 // ~150 MB
        
    }

    func image(forKey key: String) -> UIImage? {
        return self.cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        self.cache.setObject(image, forKey: key as NSString, cost: cost)
        
    }
    
}

struct DownsampledRemoteImage: View {
    
    let url: URL
    let targetSize: CGSize
    let scale: CGFloat
    let contentMode: ContentMode
    let placeholder: AnyView?

    @State private var uiImage: UIImage?
    @State private var isLoading: Bool = false

    init(url: URL,
         targetSize: CGSize,
         scale: CGFloat = UIScreen.main.scale,
         contentMode: ContentMode = .fill,
         placeholder: AnyView? = nil) {
        
        self.url = url
        self.targetSize = targetSize
        self.scale = scale
        self.contentMode = contentMode
        self.placeholder = placeholder
        
    }

    var body: some View {
        
        Group {
            
            if let uiImage {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: self.contentMode)
                
            } else {
                
                if let placeholder {
                    placeholder
                } else {
                    Color.clear
                }
                
            }
            
        }
        .task(id: self.cacheKey) {
            await load()
        }
    }

    private var cacheKey: String {
        
        // Include dimensions in cache key to avoid reusing wrong-sized decode
        
        let width = Int(self.targetSize.width * self.scale)
        let height = Int(self.targetSize.height * self.scale)
        
        return "\(self.url.absoluteString)|w=\(width)|h=\(height)"
        
    }

    private func load() async {
        
        if self.uiImage != nil { return }
        
        if let cached = DownsampledImageCache.shared.image(forKey: self.cacheKey) {
            
            self.uiImage = cached
            return
            
        }
        
        if self.isLoading { return }
        
        self.isLoading = true
        defer { self.isLoading = false }

        do {
            
            let request = URLRequest(url: self.url)
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if Task.isCancelled { return }

            let maxPixel = Int(max(self.targetSize.width, self.targetSize.height) * self.scale)
            
            if let downsampled = downsampleImage(data: data, maxPixelSize: maxPixel) {
                
                DownsampledImageCache.shared.setImage(downsampled, forKey: self.cacheKey)
                
                if Task.isCancelled { return }
                
                await MainActor.run {
                    self.uiImage = downsampled
                }
                
            }
            
        } catch {
            // No-op; show placeholder
        }
    }

    private func downsampleImage(data: Data, maxPixelSize: Int) -> UIImage? {
        
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false
        ]
        
        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
            return nil
        }
        
        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true
        ]
        
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions as CFDictionary) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
        
    }
    
}


