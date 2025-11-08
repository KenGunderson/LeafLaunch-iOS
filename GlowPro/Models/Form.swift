//
//  Form.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/6/25.
//

import Foundation

enum GlowProForm: String,
                  Identifiable,
                  CaseIterable {
    
    var id: String { self.rawValue }
    
    case canvas
    case face
    case body
    
    case painDiagram
    case sample
    
    var displayName: String {
        
        var name = ""
        
        switch self {
        case .canvas: name = "Canvas"
        case .face: name = "Face"
        case .body: name = "Body Diagram"
        case .painDiagram: name = "Pain Diagram"
        case .sample: name = "Sample"
        }
        
        return name
        
    }
    
    var url: URL {
        
        var name = ""
        
        switch self {
        case .canvas: name = "Canvas"
        case .face: name = "Face"
        case .body: name = "Body"
        case .painDiagram: name = "PainDiagram"
        case .sample: name = "Sample"
        }
        
        return Bundle.main
            .url(
                forResource: name,
                withExtension: "pdf"
            )!
        
    }
    
}

struct Form: Identifiable,
             Equatable,
             Hashable,
             Codable,
             Mockable {
    
    let id: String
    let locationId: String
    let title: String
    let mediaURL: URL
    
    init(id: String,
         locationId: String,
         title: String,
         mediaURL: URL) {
        
        self.id = id
        self.locationId = locationId
        self.title = title
        self.mediaURL = mediaURL
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case locationId = "location_id"
        case title
        case mediaURL = "media_url"
        
    }
    
}

extension Form {
    
    static func DUMMY_DATA() -> Self {
        
        let id = UUID().uuidString
        
        return .init(
            id: id,
            locationId: MockModels.ID.location1,
            title: "First Form",
            mediaURL: URL(string: "https://picsum.photos/id/11/1200/1200")!
        )
        
    }
    
}
