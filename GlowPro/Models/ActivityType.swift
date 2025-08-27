import SwiftUI

enum ActivityType: String, Codable, CaseIterable {
    
    case businessCreated = "BUSINESS_CREATED"
    case businessUpdated = "BUSINESS_UPDATED"
    case businessDeleted = "BUSINESS_DELETED"
    
    case locationCreated = "LOCATION_CREATED"
    case locationUpdated = "LOCATION_UPDATED"
    case locationDeleted = "LOCATION_DELETED"
    
    case employeeInvited = "EMPLOYEE_INVITED"
    case employeeCreated = "EMPLOYEE_CREATED"
    case employeeDeleted = "EMPLOYEE_DELETED"
    
    case clientCreated = "CLIENT_CREATED"
    case clientUpdated = "CLIENT_UPDATED"
    case clientDeleted = "CLIENT_DELETED"
    
    case formSubmitted = "FORM_SUBMITTED"
    
    case noteAdded = "NOTE_ADDED"
    case noteDeleted = "NOTE_DELETED"
    
    case mediaAdded = "MEDIA_ADDED"
    case mediaFavorited = "MEDIA_FAVORITED"
    case mediaDeleted = "MEDIA_DELETED"
    
    case quickNote = "QUICK_NOTE"
    case soapNote = "SOAP_NOTE"
    
    var displayName: String {
        switch self {
        case .businessCreated: return "Business Created"
        case .businessUpdated: return "Business Updated"
        case .businessDeleted: return "Business Deleted"
            
        case .locationCreated: return "Location Created"
        case .locationUpdated: return "Location Updated"
        case .locationDeleted: return "Location Deleted"
            
        case .employeeInvited: return "Employee Invited"
        case .employeeCreated: return "Employee Created"
        case .employeeDeleted: return "Employee Deleted"
            
        case .clientCreated: return "Client Created"
        case .clientUpdated: return "Client Updated"
        case .clientDeleted: return "Client Deleted"
            
        case .formSubmitted: return "Form Submitted"
            
        case .noteAdded: return "Note Added"
        case .noteDeleted: return "Note Deleted"
            
        case .mediaAdded: return "Media Added"
        case .mediaFavorited: return "Media Favorited"
        case .mediaDeleted: return "Media Deleted"
            
        case .quickNote: return "Quick Note"
        case .soapNote: return "SOAP Note"
        }
    }
    
    var tintColor: Color {
        switch self {
        case .businessCreated,
             .businessUpdated,
             .businessDeleted: return .blue
            
        case .locationCreated,
             .locationUpdated,
             .locationDeleted: return .green
            
        case .employeeInvited,
             .employeeCreated,
             .employeeDeleted: return .purple
            
        case .clientCreated,
             .clientUpdated,
             .clientDeleted: return .orange
            
        case .formSubmitted: return .teal
            
        case .noteAdded,
             .noteDeleted,
             .quickNote,
             .soapNote: return .gray
            
        case .mediaAdded,
             .mediaFavorited,
             .mediaDeleted:  return .pink
        }
    }
    
    var icon: String {
        switch self {
        case .businessCreated,
             .businessUpdated,
             .businessDeleted: return "building.2"
            
        case .locationCreated,
             .locationUpdated,
             .locationDeleted: return "mappin.and.ellipse"
            
        case .employeeInvited,
             .employeeCreated,
             .employeeDeleted: return "person.2"
            
        case .clientCreated,
             .clientUpdated,
             .clientDeleted: return "person.crop.circle"
            
        case .formSubmitted: return "doc.text"
            
        case .noteAdded,
             .noteDeleted,
             .quickNote,
             .soapNote: return "note.text"
            
        case .mediaAdded,
             .mediaFavorited,
             .mediaDeleted:  return "photo"
        }
        
    }
    
}
