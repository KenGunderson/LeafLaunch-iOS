import SwiftUI

enum ActivityType: String, Codable, CaseIterable {
    
    case businessCreated = "BUSINESS_CREATED"
    case businessUpdated = "BUSINESS_UPDATED"
    case businessDeleted = "BUSINESS_DELETED"
    
    case locationCreated = "LOCATION_CREATED"
    case locationUpdated = "LOCATION_UPDATED"
    case locationDeleted = "LOCATION_DELETED"
    
    case employeeInvited = "EMPLOYEE_INVITED"
    case employeeInviteAutoAccepted = "EMPLOYEE_INVITE_AUTO_ACCEPTED"
    case employeeInivteDeleted = "EMPLOYEE_INVITE_DELETED"
    case employeeCreated = "EMPLOYEE_CREATED"
    case employeeDeleted = "EMPLOYEE_DELETED"
    
    case clientCreated = "CLIENT_CREATED"
    case clientUpdated = "CLIENT_UPDATED"
    case clientDeleted = "CLIENT_DELETED"
    
    case formCreated = "FORM_CREATED"
    case formSubmitted = "FORM_SUBMITTED"
    
    case noteCreated = "NOTE_CREATED"
    case noteUpdated = "NOTE_UPDATED"
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
        case .employeeInivteDeleted: return "Employee Invite Deleted"
        case .employeeCreated: return "Employee Created"
        case .employeeDeleted: return "Employee Deleted"
            
        case .clientCreated: return "Client Created"
        case .clientUpdated: return "Client Updated"
        case .clientDeleted: return "Client Deleted"
            
        case .formCreated: return "Form Created"
        case .formSubmitted: return "Form Submitted"
            
        case .noteCreated: return "Note Added"
        case .noteUpdated: return "Note Updated"
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
             .businessDeleted: return ActivityCategory.business.color
            
        case .locationCreated,
             .locationUpdated,
             .locationDeleted: return ActivityCategory.location.color
            
        case .employeeInvited,
             .employeeInivteDeleted,
             .employeeCreated,
             .employeeDeleted: return ActivityCategory.employee.color
            
        case .clientCreated,
             .clientUpdated,
             .clientDeleted: return ActivityCategory.client.color
            
        case .formCreated,
             .formSubmitted : return ActivityCategory.form.color
            
        case .noteCreated,
             .noteUpdated,
             .noteDeleted,
             .quickNote,
             .soapNote: return ActivityCategory.note.color
            
        case .mediaAdded,
             .mediaFavorited,
             .mediaDeleted:  return ActivityCategory.media.color
        }
    }
    
    var icon: ImageSource {
        switch self {
        case .businessCreated,
             .businessUpdated,
             .businessDeleted: return ActivityCategory.business.icon
            
        case .locationCreated,
             .locationUpdated,
             .locationDeleted: return ActivityCategory.location.icon
            
        case .employeeInvited,
             .employeeInivteDeleted,
             .employeeCreated,
             .employeeDeleted: return ActivityCategory.employee.icon
            
        case .clientCreated,
             .clientUpdated,
             .clientDeleted: return ActivityCategory.client.icon
            
        case .formCreated,
             .formSubmitted: return ActivityCategory.form.icon
            
        case .noteCreated,
             .noteUpdated,
             .noteDeleted,
             .quickNote,
             .soapNote: return ActivityCategory.note.icon
            
        case .mediaAdded,
             .mediaFavorited,
             .mediaDeleted:  return ActivityCategory.media.icon
        }
    }
    
}

enum ActivityCategory {
    
    case business
    case location
    case employee
    case client
    case form
    case note
    case camera
    case media
    
    var icon: ImageSource {
        switch self {
        case .business:return .systemImage("storefront.fill")
        case .location: return .systemImage("pin")
        case .employee: return .systemImage("stethoscope")
        case .client: return .image(.iconPersonOutline)
        case .form: return .image(.iconFileOutline)
        case .note: return .image(.iconNoteOutline)
        case .camera: return .image(.iconCamera)
        case .media: return .systemImage("photo.on.rectangle.fill")
        }
    }
    
    var color: Color {
        switch self {
        case .business: return GPColor.iconBlue
        case .location: return GPColor.iconGreen
        case .employee: return GPColor.iconAmber
        case .client: return GPColor.iconPurple
        case .form: return GPColor.iconRed
        case .note: return GPColor.iconPink
        case .camera: return GPColor.iconTeal
        case .media: return GPColor.iconTeal
        }
    }
    
}
