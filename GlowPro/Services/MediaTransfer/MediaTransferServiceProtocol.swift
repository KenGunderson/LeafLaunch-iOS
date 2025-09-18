//
//  MediaTransferServiceProtocol.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/18/25.
//

import Combine
import Foundation

protocol MediaTransferServiceProtocol {
    
    var mediaPublisher: PassthroughSubject<[Media], Never> { get }
    var mediaURLsPublisher: PassthroughSubject<[URL], Never> { get }
    
    func sendMedia(_ media: [Media])
    func sendURLs(_ url: [URL])
    
}
