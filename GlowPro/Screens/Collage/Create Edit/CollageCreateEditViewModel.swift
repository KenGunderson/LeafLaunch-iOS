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
        
    @Published private(set) var selectedMediaURLs: [MediaFusion?] = [nil, nil, nil, nil]
    @Published private(set) var selectedCollageType: CollageType = .grid(rows: 1, columns: 2)
    
    var maxNumberOfMedia: Int {
        
        let maxNumberOfColumns: Int = self.selectedCollageType.rowsAndColumns.columns
        let maxNumberOfRows: Int = self.selectedCollageType.rowsAndColumns.rows
        return maxNumberOfColumns * maxNumberOfRows
        
    }
    
    var isSaveButtonEnabled: Bool {
        
        let validSelectedURLs = self.selectedMediaURLs.compactMap { $0 }
        
        return (
            !validSelectedURLs.isEmpty &&
            validSelectedURLs.count >= self.maxNumberOfMedia
        )
        
    }
    
    var isOwnerOrManager: Bool {
        return self.activeDestinationService.isOwnerOrManager
    }
    
    var isCreateContext: Bool {
        return self.collageId == nil
    }
    
    private var client: Client?
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
        
        guard let clientId else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let client = try await self.apiService.getClient(id: clientId)
                
                await MainActor.run {
                    self.client = client
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("client"),
                            action: {
                                
                                self.navigationService?
                                    .popWithDelay()
                                
                            })
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func navigate(to route: Route) {
        
        self.navigationService?
            .push(route)
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func pushMediaSelection(index: Int) {
        
        self.navigationService?
            .push(.media(
                .gallery(
                    mediaContext: .client(clientId: self.clientId),
                    mediaSelectionContext: .singleSelection(completion: { media in
                        
                        self.selectedMediaURLs[index] = .init(
                            id: media?.id ?? "",
                            kind: .url(media!.url),
                            isUploaded: true,
                            media: media
                        )
                        
                    }))
            ))
        
    }
    
    func set(collageType: CollageType) {
        self.selectedCollageType = collageType
    }
    
    func saveOrUpdate() {
        save()
    }
    
    private func save() {
        
        guard let client else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let allMedia = Array(self.selectedMediaURLs.compactMap({ $0?.media?.url }).prefix(self.maxNumberOfMedia))
                
                let newCollage = Collage(
                    id: UUID().uuidString,
                    locationId: client.locationId ?? "",
                    clientId: self.clientId,
                    mediaURLs: allMedia,
                    rowCount: self.selectedCollageType.rowsAndColumns.rows,
                    columnCount: selectedCollageType.rowsAndColumns.columns,
                    type: selectedCollageType
                )
                
                try await self.apiService
                    .createCollage(collage: newCollage)
                
                self.viewLifecycleService
                    .reload(for: .collageList)
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Collage created successfully.",
                        action: {
                            
                            self.navigationService?
                                .popWithDelay()
                            
                        }
                        
                    ))))
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: "Something went wrong while saving your collage. Please try again later.",
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }
    
    func deleteMediaURL(id: String) {
        
        self.selectedMediaURLs
            .removeAll(where: { $0?.id == id })
        
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
