//
//  Note.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/13/25.
//

import Foundation

enum NoteType: String, Codable, CaseIterable {
    
    case quick = "QUICK"
    case soap = "SOAP"
    case advanced = "ADVANCED"
    
    var displayName: String {
        
        switch self {
        case .quick: return "Basic"
        case .soap: return "SOAP"
        case .advanced: return "Advanced"
        }
        
    }
    
    var longDisplayName: String {
        
        switch self {
        case .quick: return "Basic Note"
        case .soap: return "SOAP Note"
        case .advanced: return "Advanced Note"
        }
        
    }
    
    var backgroundColor: ColorSource {
        
        switch self {
        case .quick: return .color(GPColor.iconBlue)
        case .soap: return .color(GPColor.iconGreen)
        case .advanced: return .color(GPColor.iconAmber)
        }
        
    }
    
}

struct NoteMetadata: Codable, Equatable, Hashable {
    
    // ADVANCED
    
    let treatmentType: String?
    let sessionNumber: String?
    let productDevicesUsed: String?
    let dosage: String?
    let treatmentNotes: String?
    let outcome: String?
    let treatedBy: String?
    let reviewedBy: String?
    
    // SOAP
    
    let soapS: String?
    let soapO: String?
    let soapA: String?
    let soapP: String?
    
    private enum CodingKeys: String, CodingKey {
        
        case treatmentType = "treatment_type"
        case sessionNumber = "session_number"
        case productDevicesUsed = "product_devices_used"
        case dosage
        case treatmentNotes = "treatment_notes"
        case outcome
        case treatedBy = "treated_by"
        case reviewedBy = "reviewed_by"
        
        case soapS = "soap_s"
        case soapO = "soap_o"
        case soapA = "soap_a"
        case soapP = "soap_p"
        
    }
    
    func toDictionary() -> [String: Any] {
        
        return [
            "treatment_type": self.treatmentType,
            "session_number": self.sessionNumber,
            "product_devices_used": self.productDevicesUsed,
            "dosage": self.dosage,
            "treatment_notes": self.treatmentNotes,
            "outcome": self.outcome,
            "soap_s": self.soapS,
            "soap_o": self.soapO,
            "soap_a": self.soapA,
            "soap_p": self.soapP,
            "treated_by": self.treatedBy,
            "reviewed_by": self.reviewedBy
        ]
            .compact()
        
    }
    
}

struct Note: Identifiable,
             Codable,
             Hashable,
             Equatable,
             Mockable {
    
    let id: String
    let clientId: String
    let employeeId: String
    
    let title: String
    let message: String
    
    let type: NoteType
    let metadata: NoteMetadata?
    
    let employeeSignature: String?
    let mediaURLs: [URL]
    let media: [Media]
    
    private var _createdAt: String?
    
    var createdAt: Date? {

        self._createdAt?
            .toDate(region: .local)?
            .date

    }
    
    init(id: String,
         clientId: String,
         employeeId: String,
         title: String,
         message: String,
         type: NoteType = .quick,
         metadata: NoteMetadata? = nil,
         employeeSignature: String?,
         mediaURLs: [URL] = [],
         media: [Media] = [],
         createdAt: String) {
        
        self.id = id
        self.clientId = clientId
        self.employeeId = employeeId
        self.title = title
        self.message = message
        self.type = type
        self.metadata = metadata
        self.employeeSignature = employeeSignature
        self.mediaURLs = mediaURLs
        self.media = media
        self._createdAt = createdAt
        
    }
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case clientId = "client_id"
        case employeeId = "employee_id"
        
        case title
        case message
        
        case type
        case metadata
        
        case employeeSignature = "employee_signature"
        
        case mediaURLs = "media_urls"
        case media = "media_objects"
        case _createdAt = "created_at"
        
    }
    
}

extension Note {
    
    static func DUMMY_DATA() -> Self {
        
        return .init(
            id: UUID().uuidString,
            clientId: "1",
            employeeId: "1",
            title: "My First Note",
            message: "This is my first note; I hope it works!",
            employeeSignature: "Sako Hovaguimian",
            createdAt: Date().dateByAdding(-10, .day).toISO()
        )
        
    }
    
}
