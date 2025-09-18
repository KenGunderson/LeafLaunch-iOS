//
//  MediaTransferService.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/18/25.
//

import Foundation
import Combine

final class MediaTransferService: MediaTransferServiceProtocol {
 
    internal let loggerName: String = "MEDIA_TRANSFER_SERVICE"
    internal let loggerEmoji: String = "🚛"
    
    var mediaPublisher = PassthroughSubject<[Media], Never>()
    var mediaURLsPublisher = PassthroughSubject<[URL], Never>()
    
    func sendMedia(_ media: [Media]) {
        self.mediaPublisher.send(media)
    }
    
    func sendURLs(_ url: [URL]) {
        self.mediaURLsPublisher.send(url)
    }
    
}
