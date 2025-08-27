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
             .businessDeleted: return GPColor.iconBlue
            
        case .locationCreated,
             .locationUpdated,
             .locationDeleted: return GPColor.iconGreen
            
        case .employeeInvited,
             .employeeCreated,
             .employeeDeleted: return GPColor.iconOrange
            
        case .clientCreated,
             .clientUpdated,
             .clientDeleted: return GPColor.iconPurple
            
        case .formSubmitted: return GPColor.iconRed
            
        case .noteAdded,
             .noteDeleted,
             .quickNote,
             .soapNote: return GPColor.iconPink
            
        case .mediaAdded,
             .mediaFavorited,
             .mediaDeleted:  return GPColor.iconTeal
        }
    }
    
    var icon: ImageSource {
        switch self {
        case .businessCreated,
             .businessUpdated,
             .businessDeleted: return .systemImage("storefront")
            
        case .locationCreated,
             .locationUpdated,
             .locationDeleted: return .systemImage("pin")
            
        case .employeeInvited,
             .employeeCreated,
             .employeeDeleted: return .image(.iconPersonOutline)
            
        case .clientCreated,
             .clientUpdated,
             .clientDeleted: return .image(.iconPerson2Outline)
            
        case .formSubmitted: return .image(.iconFileOutline)
            
        case .noteAdded,
             .noteDeleted,
             .quickNote,
             .soapNote: return .image(.iconNoteOutline)
            
        case .mediaAdded,
             .mediaFavorited,
             .mediaDeleted:  return .image(.iconCamera)
        }
        
    }
    
}
