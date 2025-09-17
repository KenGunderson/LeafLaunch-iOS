//
//  Routes.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import Foundation

protocol Navigation {
    //
}

enum Route: Navigation, Hashable, Sendable {
    
    enum Auth {
        
        case welcome
        case login
        case signup
        
    }
    
    enum Onboarding: Hashable {
        
        case businessSetup
        case locationControl
        case photos
        case beforeAndAfter
        case documentation
        case permission
        
    }
    
    enum Business: Hashable {
        
        case businessHome(businessId: String)
        case businessDetails(businessId: String)
        case businessCreateEdit(businessId: String?)
        
        case businessLocationHome(locationId: String,
                                  completion: (() -> ())? = nil)
                                  
        case businessLocationList(businessId: String)
        
        case businessLocationCreateEdit(businessId: String,
                                        locationId: String? = nil)
                
        case businessEmployees(businessId: String,
                               context: BusinessEmployeesViewModel.Context)
        
        case businessEmployeesInvite(businessId: String)
        case businessEmployeeInviteList(context: BusinessEmployeeInviteListViewModel.Context)
        case businessEmployeesUpdate(businessId: String, employeeId: String)
        case businessEmployeeDetails(businessId: String, employeeId: String)
        
        case businessActivitiesList(context: BusinessActivityListViewModel.Context)
        
    }
    
    enum Client: Hashable {
        
        case clientCreate(locationId: String,
                          clientId: String? = nil)
        
        case clientList(context: ClientListViewModel.Context)
        
        case clientHome(clientId: String)
        
    }
    
    enum MediaRoute: Hashable {
        
        case camera(context: MediaContext,
                    mode: CameraCaptureMode)
        
        case preview(selectedMedia: Media?,
                     media: [Media])
        
        case gallery(mediaContext: MediaContext,
                     mediaSelectionContext: MediaSelectionContext)
        
    }
    
    enum NoteRoute: Hashable {
        
        case noteList(clientId: String)
        
        case noteCreateEdit(context: NoteCreateEditViewModel.Context,
                            clientId: String)
        
    }
    
    enum Setting: String, CaseIterable {
        
        case profile
        case subscription
        case aboutUs
        case frequentlyAskedQuestions
        case contactSupport
        case featureRequest
        case writeAReview
        case privacyPolicy
        case termsOfService
        case logout
        
        var displayName: String {
            switch self {
            case .profile: return "Update Profile"
            case .subscription: return "Manage Subscription"
            case .aboutUs: return "About Us"
            case .frequentlyAskedQuestions: return "Frequently Asked Questions"
            case .contactSupport: return "Contact Support"
            case .featureRequest: return "Feature Request"
            case .writeAReview: return "Write a Review"
            case .privacyPolicy: return "Privacy Policy"
            case .termsOfService: return "Terms of Service"
            case .logout: return "Logout"
            }
        }
        
        var icon: ImageSource {
            switch self {
            case .profile: return .image(.iconPerson)
            case .subscription: return .image(.iconShoppingCart)
            case .aboutUs: return .image(.iconInfoCircle)
            case .frequentlyAskedQuestions: return .image(.iconQuestionMark)
            case .contactSupport: return .image(.iconMail)
            case .featureRequest: return .systemImage("lightbulb.fill")
            case .writeAReview: return .systemImage("star.fill")
            case .privacyPolicy: return .image(.iconLock)
            case .termsOfService: return .systemImage("clipboard.fill")
            case .logout: return .image(.iconCloseCircle)
            }
        }
        
        var tintColor: ColorSource {
            switch self {
            case .logout: Style.shared.background(.error)
            default: Style.shared.accent
            }
        }
        
        var category: String {
            switch self {
            case .profile, .subscription: return "Account"
            case .aboutUs, .frequentlyAskedQuestions, .contactSupport, .featureRequest, .writeAReview: return "Help & Feedback"
            case .privacyPolicy, .termsOfService: return "Legal"
            case .logout: return "Logout"
            }
        }
        
    }
    
    enum DevSetting: String, CaseIterable {
        
        case components
        case userDefaults
        case routes
        case deeplinks
        case analytics
        case impersonate
        
        var displayName: String {
            switch self {
            case .components: return "Components"
            case .userDefaults: return "User Defaults"
            case .routes: return "Routes"
            case .deeplinks: return "Deeplinks"
            case .analytics: return "Analytics"
            case .impersonate: return "Impersonate"
            }
        }
        
        var icon: String {
            switch self {
            case .components: return "wrench.and.screwdriver.fill"
            case .userDefaults: return "flag.fill"
            case .routes: return "car.rear.road.lane"
            case .deeplinks: return "link.circle.fill"
            case .analytics: return "chart.line.uptrend.xyaxis"
            case .impersonate: return "person.crop.square.filled.and.at.rectangle.fill"
            }
        }
        
        var routeForDevSetting: Route {
            switch self {
            case .components: return .devSetting(.components)
            case .userDefaults: return .devSetting(.userDefaults)
            case .routes: return .devSetting(.routes)
            case .deeplinks: return .devSetting(.deeplinks)
            case .analytics: return .devSetting(.analytics)
            case .impersonate: return .devSetting(.impersonate)
            }
        }
        
    }
    
    case devSetting(DevSetting)
    case auth(Auth)
    case onboarding(Onboarding)
    case setting(Setting)
    case business(Business)
    case client(Client)
    case media(MediaRoute)
    case note(NoteRoute)
    
}

extension Route.Business {
    
    static func == (lhs: Route.Business, rhs: Route.Business) -> Bool {
        
        switch (lhs, rhs) {
        case let (.businessHome(id1), .businessHome(id2)):
            return id1 == id2
        case let (.businessDetails(id1), .businessDetails(id2)):
            return id1 == id2
        case let (.businessCreateEdit(id1), .businessCreateEdit(id2)):
            return id1 == id2
        case let (.businessLocationHome(id1, _), .businessLocationHome(id2, _)):
            return id1 == id2
        case let (.businessLocationList(id1), .businessLocationList(id2)):
            return id1 == id2
        case let (.businessLocationCreateEdit(b1, l1),
                  .businessLocationCreateEdit(b2, l2)):
            return b1 == b2 && l1 == l2
        case let (.businessEmployees(b1, c1), .businessEmployees(b2, c2)):
            return b1 == b2 && c1 == c2
        case let (.businessEmployeesInvite(b1), .businessEmployeesInvite(b2)):
            return b1 == b2
        case let (.businessEmployeeInviteList(c1), .businessEmployeeInviteList(c2)):
            return c1 == c2
        case let (.businessEmployeesUpdate(b1, e1), .businessEmployeesUpdate(b2, e2)):
            return b1 == b2 && e1 == e2
        case let (.businessEmployeeDetails(b1, e1), .businessEmployeeDetails(b2, e2)):
            return b1 == b2 && e1 == e2
        case let (.businessActivitiesList(c1), .businessActivitiesList(c2)):
            return c1 == c2
        default:
            return false
        }
        
    }
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case let .businessHome(id):
            hasher.combine(0)
            hasher.combine(id)
        case let .businessDetails(id):
            hasher.combine(1)
            hasher.combine(id)
        case let .businessCreateEdit(id):
            hasher.combine(2)
            hasher.combine(id)
        case let .businessLocationHome(id, _):
            hasher.combine(3)
            hasher.combine(id)
        case let .businessLocationList(id):
            hasher.combine(4)
            hasher.combine(id)
        case let .businessLocationCreateEdit(b, l):
            hasher.combine(5)
            hasher.combine(b)
            hasher.combine(l)
        case let .businessEmployees(b, c):
            hasher.combine(7)
            hasher.combine(b)
            hasher.combine(c)
        case let .businessEmployeesInvite(b):
            hasher.combine(8)
            hasher.combine(b)
        case let .businessEmployeeInviteList(c):
            hasher.combine(9)
            hasher.combine(c)
        case let .businessEmployeesUpdate(b, e):
            hasher.combine(10)
            hasher.combine(b)
            hasher.combine(e)
        case let .businessEmployeeDetails(b, e):
            hasher.combine(11)
            hasher.combine(b)
            hasher.combine(e)
        case let .businessActivitiesList(c):
            hasher.combine(12)
            hasher.combine(c)
        }
        
    }
    
}
