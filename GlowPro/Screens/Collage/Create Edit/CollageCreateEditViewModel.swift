//
//  CollageCreateEditViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/18/25.
//

import Combine
import Foundation

final class CollageCreateEditViewModel: ViewModel {
    
    enum CollageTypeOptions: String, CaseIterable {
        
        case row1Column2
        case row2Column1
        case oneLargeTwoSmall
        case oneLargeOneSmall
        case oneSmallOneLarge
        case twoLargeTwoSmall
        
        var numberOfRows: Int {
            
            switch self {
            case .row1Column2: return 1
            case .row2Column1: return 2
            case .oneLargeTwoSmall: return 1
            case .oneLargeOneSmall: return 1
            case .oneSmallOneLarge: return 1
            case .twoLargeTwoSmall: return 2
            }
            
        }
        
        var numberOfColumns: Int {
            
            switch self {
            case .row1Column2: return 2
            case .row2Column1: return 1
            case .oneLargeTwoSmall: return 2
            case .oneLargeOneSmall: return 1
            case .oneSmallOneLarge: return 1
            case .twoLargeTwoSmall: return 2
            }
            
        }
        
        var collageType: CollageType {
            
            switch self {
            case .row1Column2: return .grid(rows: 1, columns: 2)
            case .row2Column1: return .grid(rows: 2, columns: 1)
            case .oneLargeTwoSmall: return .oneLargeTwoSmall
            case .oneLargeOneSmall: return .oneLargeOneSmall
            case .oneSmallOneLarge: return .oneSmallOneLarge
            case .twoLargeTwoSmall: return .twoLargeTwoSmall
            }
            
        }
        
    }
    
    internal let loggerName: String = "COLLAGE_CREATE_EDIT_VIEW_MODEL"
    internal let loggerEmoji: String = "🎞️"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
        
    @Published private(set) var selectedMediaURLs: [MediaFusion] = []
    @Published private(set) var selectedCollageType: CollageType?
    
    var isSaveButtonEnabled: Bool {
        
        let maxNumberOfColumns: Int = self.selectedCollageType?.rowsAndColumns.columns ?? 0
        let maxNumberOfRows: Int = self.selectedCollageType?.rowsAndColumns.rows ?? 0
        let maxNumberOfMedia: Int = maxNumberOfColumns * maxNumberOfRows
        
        return (
            !self.selectedMediaURLs.isEmpty &&
            self.selectedCollageType != nil &&
            self.selectedMediaURLs.count >= maxNumberOfMedia
        )
        
    }
    
    var isOwnerOrManager: Bool {
        return self.activeDestinationService.isOwnerOrManager
    }
    
    var isCreateContext: Bool {
        return self.collageId == nil
    }
    
    private(set) var clientId: String!
    private var collageId: String?

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    var navTitle: String {
        return self.isCreateContext ? "Create Collage" : "Edit Collage"
    }
    
    var saveButtonTitle: String {
        return self.isCreateContext ? "Create" : "Save"
    }
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        
        self.logInit()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(clientId: String? = nil,
               collageId: String? = nil) -> Self {
        
        self.clientId = clientId
        self.collageId = collageId
        
        return self
        
    }
    
    func loadData() {
        
//        guard let clientId else { return }
//        
//        self.alertService
//            .showAlert(.init(.simpleLoadingIndicator))
//        
//        Task {
//            
//            do {
//                
//                let client = try await self.apiService.getClient(id: clientId)
//                
//                await MainActor.run {
//                    
//                    self.firstName = client.firstName
//                    self.lastName = client.lastName
//                    self.phone = client.phoneNumber ?? ""
//                    self.email = client.email ?? ""
//                    
//                }
//                
//            }
//            catch {
//                
//                self.alertService.showAlert(.init(
//                    .appAlert(
//                        .error(
//                            message: Constants.Message.errorMessage("client"),
//                            action: {
//                                
//                                self.navigationService?
//                                    .popWithDelay()
//                                
//                            })
//                    ))
//                )
//                
//            }
//            
//            self.alertService
//                .dismissLoadingIndicator()
//            
//        }
        
    }
    
    func navigate(to route: Route) {
        
        self.navigationService?
            .push(route)
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func set(media: Media?) {
        
        self.selectedMediaURLs.append(.init(
            id: media?.id ?? "",
            kind: .url(media!.url),
            isUploaded: true,
            media: media
        ))
        
    }
    
    func set(collageType: CollageType?) {
        
        if self.selectedCollageType == collageType {
            self.selectedCollageType = nil
        } else {
            self.selectedCollageType = collageType
        }
        
    }
    
    func saveOrUpdate() {
        save()
    }
    
    private func save() {
        
//        guard let currentUser = self.authService.currentUser else { return }
//        
//        if !email.isEmpty,
//           !self.email.isValidEmail() {
//            
//            self.alertService
//                .showAlert(Constants.INVALID_EMAIL_ALERT())
//            
//            return
//            
//        }
//        
//        self.alertService
//            .showAlert(.init(.simpleLoadingIndicator))
//        
//        Task {
//            
//            do {
//                
//                let employeeId = try await self.apiService.getEmployeeByUserIdForLocation(
//                    userId: currentUser.id,
//                    locationId: self.locationId ?? ""
//                )
//                
//                let isValidDateOfBirth = !self.dateOfBirth.isToday
//                let dateOfBirth = isValidDateOfBirth ? self.dateOfBirth.ISO8601Format() : nil
//                
//                let newClient = Client(
//                    id: UUID().uuidString,
//                    firstName: self.firstName,
//                    lastName: self.lastName,
//                    email: self.email.isEmpty ? nil : self.email,
//                    phone: self.phone.isEmpty ? nil : self.phone,
//                    dateOfBirth: dateOfBirth,
//                    locationId: self.locationId ?? "",
//                    employeeId: employeeId
//                )
//                
//                try await self.apiService
//                    .createClient(
//                        client: newClient,
//                        locationId: self.locationId ?? ""
//                    )
//                
//                self.viewLifecycleService
//                    .reload(for: .clientList)
//                
//                self.alertService
//                    .showAlert(.init(.appAlert(.success(
//                        message: "Client created successfully.",
//                        action: {
//                            
//                            self.navigationService?
//                                .popWithDelay()
//                            
//                        }
//                        
//                    ))))
//                
//            }
//            catch {
//                
//                self.alertService.showAlert(.init(
//                    .appAlert(
//                        .error(
//                            message: "Something went wrong while saving your client. Please try again later.",
//                            action: {})
//                    ))
//                )
//                
//            }
//            
//            self.alertService.dismissLoadingIndicator()
//            
//        }
        
    }
    
    func deleteMediaURL(id: String) {
        
        self.selectedMediaURLs
            .removeAll(where: { $0.id == id })
        
    }

    func presentDeleteCollageAlert() {
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: Constants.Message.deleteConfirmationTitle("Collage"),
                message: Constants.Message.deleteConfirmationMessage("collage"),
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    self?.deleteCollage()
                },
                primaryButtonBackgroundColor: Style.shared.background(.error),
                primaryButtonTextColor: Style.shared.textColor(.titleInverted),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.quaternary),
                secondaryButtonTextColor: Style.shared.textColor(.title)
            ))))
        
    }
    
    private func deleteCollage() {
        
        Task {
            
            do {
                
                try await self.apiService
                    .deleteCollage(collageId: self.collageId ?? "")
                
                await MainActor.run { [weak self] in
                    
                    self?.viewLifecycleService
                        .reload(for: .collageList)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.navigationService?.pop()
                    }
                    
                }
                
            }
            catch {
                
                self.alertService
                    .showAlert(.init(.appAlert(.error(
                        message: Constants.Message.errorMessage(context: .delete, "collage"),
                        action: {})
                    )))
                
            }
            
        }
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension CollageCreateEditViewModel {
    
    func track() {
        self.analyticsService.track(screen: .collage(.collageCreateEdit(collageId: self.collageId)))
    }
    
}
