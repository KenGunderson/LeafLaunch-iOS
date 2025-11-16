//
//  Routes.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 7/16/24.
//

import UIKit

protocol Navigation {
    //
}

enum Route: Navigation, Hashable, Sendable {
    
    enum AuthRoute {
        
        case welcome
        case login
        case signup
        
    }
    
    enum OnboardingRoute: Hashable {
        
        case businessSetup
        case locationControl
        case photos
        case beforeAndAfter
        case documentation
        case permission
        
    }
    
    enum BusinessRoute: Hashable, Sendable {
        
        case businessHome(businessId: String)
        case businessDetails(businessId: String)
        case businessCreateEdit(businessId: String?)
        
        case businessLocationHome(locationId: String,
                                  completion: (() -> ())? = nil)
                                  
        case businessLocationList(businessId: String)
        
        case businessLocationCreateEdit(businessId: String,
                                        locationId: String? = nil)
                
        case businessEmployees(businessId: String,
                               context: BusinessEmployeeListViewModel.Context)
        
        case businessEmployeesInvite(businessId: String,
                                     context: BusinessEmployeeInviteViewModel.Context)
        
        case businessEmployeeInviteList(context: BusinessEmployeeInviteListViewModel.Context)
        case businessEmployeesUpdate(businessId: String, employeeId: String)
        case businessEmployeeDetails(businessId: String, employeeId: String)
        
        case businessActivitiesList(context: BusinessActivityListViewModel.Context)
        
    }
    
    enum ClientRoute: Hashable {
        
        case clientCreate(locationId: String,
                          clientId: String? = nil)
        
        case clientList(context: ClientListViewModel.Context)
        
        case clientHome(clientId: String)
        
    }
    
    enum MediaRoute: Hashable, Sendable {
        
        case camera(context: MediaContext,
                    mode: CameraCaptureMode)
        
        case preview(selectedMedia: Media?,
                     media: [Media])
        
        case gallery(mediaContext: MediaContext,
                     mediaSelectionContext: MediaSelectionContext,
                     mediaFilterOptions: MediaType = .image)
        
        case review(context: MediaReviewViewModel.Context,
                    images: [UIImage],
                    removeAction: (UIImage) -> Void)
        
    }
    
    enum CollageRoute: Hashable, Sendable {
                
        case createEdit(clientId: String?,
                        collageId: String?)
        
    }
    
    enum NoteRoute: Hashable {
        
        case noteList(clientId: String)
        
        case noteCreateEdit(context: NoteCreateEditViewModel.Context,
                            noteType: NoteType? = nil,
                            clientId: String)
        
    }
    
    enum FormRoute: Hashable, Sendable {
        
        case formList(context: FormListViewModel.Context,
                      mode: FormListViewModel.Mode)
        
        case formCreateEdit(formId: String?,
                            mediaURL: URL?)
        
    }
    
    enum SettingRoute: String, CaseIterable {
        
        case profile
        case subscribe
        case manageSubscription
        case security
        case updatePermissions
        case aboutUs
        case frequentlyAskedQuestions
        case contactSupport
        case featureRequest
        case rateApp
        case privacyPolicy
        case termsOfService
        case logout
        
        var displayName: String {
            switch self {
            case .profile: return "Update Profile"
            case .subscribe: return "Subscribe"
            case .manageSubscription: return "Manage Subscription"
            case .security: return "Security"
            case .updatePermissions: return "Update Permissions"
            case .aboutUs: return "About Us"
            case .frequentlyAskedQuestions: return "Frequently Asked Questions"
            case .contactSupport: return "Contact Support"
            case .featureRequest: return "Feature Request"
            case .rateApp: return "Rate Our App"
            case .privacyPolicy: return "Privacy Policy"
            case .termsOfService: return "Terms of Service"
            case .logout: return "Logout"
            }
        }
        
        var icon: ImageSource {
            switch self {
            case .profile: return .image(.iconPerson)
            case .subscribe: return .image(.iconShoppingCart)
            case .manageSubscription: return .image(.iconShoppingCart)
            case .security: return .systemImage("lock.fill")
            case .updatePermissions: return .systemImage("shield.fill")
            case .aboutUs: return .image(.iconInfoCircle)
            case .frequentlyAskedQuestions: return .image(.iconQuestionMark)
            case .contactSupport: return .image(.iconMail)
            case .featureRequest: return .systemImage("lightbulb.fill")
            case .rateApp: return .systemImage("star.fill")
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
            case .profile, .subscribe, .manageSubscription, .security, .updatePermissions: return "Account"
            case .aboutUs, .frequentlyAskedQuestions, .contactSupport, .featureRequest, .rateApp: return "Help & Feedback"
            case .privacyPolicy, .termsOfService: return "Legal"
            case .logout: return "Logout"
            }
        }
        
    }
    
    enum DevSettingRoute: String, CaseIterable {
        
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
    
    case devSetting(DevSettingRoute)
    case auth(AuthRoute)
    case onboarding(OnboardingRoute)
    case setting(SettingRoute)
    case business(BusinessRoute)
    case client(ClientRoute)
    case media(MediaRoute)
    case collage(CollageRoute)
    case note(NoteRoute)
    case form(FormRoute)
    
}

extension Route.BusinessRoute {
    
    static func == (lhs: Route.BusinessRoute, rhs: Route.BusinessRoute) -> Bool {
        
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
        case let (.businessEmployeesInvite(b1, _), .businessEmployeesInvite(b2, _)):
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
        case let .businessEmployeesInvite(b, _):
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

extension Route.FormRoute {
    
    static func == (lhs: Route.FormRoute, rhs: Route.FormRoute) -> Bool {
        
        switch (lhs, rhs) {
        case let (.formList(_, mode), .formList(_, mode2)): return mode == mode2
        case let (.formCreateEdit(id, _), .formCreateEdit(id2, _)): return id == id2
        case (.formCreateEdit(formId: let formId, _), .formList(context: let context, mode: _)): return formId == context.analyticsName
        case (.formList(context: let context, _), .formCreateEdit(formId: let formId, _)): return formId == context.analyticsName
        }
        
    }
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case let .formList(_, id):
            hasher.combine(0)
            hasher.combine(id)
        case let .formCreateEdit(formId, _):
            hasher.combine(formId)
        }
        
    }
    
}

extension Route.MediaRoute {
    
    static func == (lhs: Route.MediaRoute, rhs: Route.MediaRoute) -> Bool {
        
        switch (lhs, rhs) {
        case (.camera, .camera): return true
        case (.preview, .preview): return true
        case (.gallery, .gallery): return true
        case (.review, .review): return true
        default: return false
        }
        
    }
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case .camera: hasher.combine(0)
        case .preview: hasher.combine(1)
        case .gallery: hasher.combine(2)
        case .review: hasher.combine(3)
        }
        
    }
    
}
