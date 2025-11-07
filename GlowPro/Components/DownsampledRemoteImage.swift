//
//  DownsampledRemoteImage.swift
//  GlowPro
//
//  Created by AI on 11/6/25.
//

import SwiftUI
import ImageIO
#if canImport(UIKit)
import UIKit
#endif

final class DownsampledImageCache {
    
    static let shared = DownsampledImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let ioQueue = DispatchQueue(label: "DOWNSAMPLED_IMAGE_CACHE_IO")
    
    // Directory in Library/Caches where we store disk images
    private lazy var directoryURL: URL = {
        
        let baseURL = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? self.fileManager.temporaryDirectory
        
        let dir = baseURL.appendingPathComponent("DownsampledImageCache", isDirectory: true)
        
        if self.fileManager.fileExists(atPath: dir.path) == false {
            try? self.fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        
        return dir
        
    }()
    
    private init() {
        
        // Reasonable upper bound; adjust if needed
        self.cache.totalCostLimit = 150 * 1024 * 1024 // ~150 MB
        
    }
    
    // MARK: - Public API
    
    func image(forKey key: String) -> UIImage? {
        
        // 1. In-memory cache
        if let cached = self.cache.object(forKey: key as NSString) {
            return cached
        }
        
        // 2. Disk cache
        let fileURL = self.fileURL(forKey: key)
        
        guard self.fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        guard
            let data = try? Data(contentsOf: fileURL),
            let image = UIImage(data: data)
        else {
            return nil
        }
        
        // Re-insert into in-memory cache
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        self.cache.setObject(image, forKey: key as NSString, cost: cost)
        
        return image
        
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        self.cache.setObject(image, forKey: key as NSString, cost: cost)
        
        // Persist on disk asynchronously
        self.ioQueue.async { [weak self] in
            
            guard let fileURL = self?.fileURL(forKey: key) else { return }
            
            // Prefer JPEG to keep size reasonable; tweak quality as needed
            guard let data = image.jpegData(compressionQuality: 0.9) else {
                return
            }
            
            do {
                
                try data.write(to: fileURL, options: [.atomic])
                
            } catch {
                // You can hook up your logger here if you want
                // print("Disk cache write error: \(error)")
            }
            
        }
        
    }
    
    // Optional: a way to clear everything if needed
    func clearAll() {
        
        self.cache.removeAllObjects()
        
        self.ioQueue.async { [weak self] in
            
            guard let strongSelf = self else { return }
            
            do {
                if strongSelf.fileManager.fileExists(atPath: strongSelf.directoryURL.path) {
                    try strongSelf.fileManager.removeItem(at: strongSelf.directoryURL)
                }
                
                try strongSelf.fileManager.createDirectory(
                    at: strongSelf.directoryURL,
                    withIntermediateDirectories: true
                )
                
            } catch {
                // print("Disk cache clear error: \(error)")
            }
            
        }
        
    }
    
    // MARK: - Helpers
    
    private func fileURL(forKey key: String) -> URL {
        
        // Sanitize key to make it file-system safe
        let sanitized = key
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: ":", with: "_")
            .replacingOccurrences(of: "?", with: "_")
            .replacingOccurrences(of: "|", with: "_")
        
        return self.directoryURL
            .appendingPathComponent(sanitized)
            .appendingPathExtension("jpg")
        
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
