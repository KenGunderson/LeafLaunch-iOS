//
//  FullScreenCover.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import Foundation
import PDFKit

enum FullScreenCover: Identifiable, Hashable, Equatable {

    case settings
    case devSettings
    case onboarding
    
    case mediaTags(selectedMedia: Media?)
    case mediaMultiTags(selectedMedia: [Media])
    case mediaPreview(context: MediaURLPreviewView.Context)
    
    case subscriptionPaywall(context: SubscriptionPaywallViewModel.Context,
                             paywallItem: SubscriptionPaywallItem,
                             completion: (() -> Void)? = nil)
    
    case subscriptionManage(businessId: String)
    
    case pdfEditor(pdfDocument: PDFDocument,
                   isReadOnly: Bool = false,
                   completion: (Data) -> Void)

    var id: String {
        return String(self.hashValue)
    }
    
    static func == (lhs: FullScreenCover, rhs: FullScreenCover) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case .devSettings: return hasher.combine(0)
        case .onboarding: return hasher.combine(1)
        case .settings: return hasher.combine(2)
        case .mediaTags(let selectedMedia): return hasher.combine(selectedMedia?.id)
        case .mediaMultiTags(let selectedMedia): return hasher.combine(selectedMedia.first?.id)
        case .mediaPreview(let ctx): return hasher.combine(ctx)
        case .subscriptionPaywall(_, let item, _): return hasher.combine(item.id)
        case .subscriptionManage(let businessId): return hasher.combine(businessId)
        case .pdfEditor(let pdfDocument, _, _): return hasher.combine(pdfDocument.documentURL?.absoluteString ?? "")
        }
        
    }
    
}
