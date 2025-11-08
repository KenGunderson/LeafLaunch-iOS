//
//  CollageCreateEditViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 10/18/25.
//

import Combine
import SwiftUI

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
    
    enum CollageContentMode: Selectable, CaseIterable {
        
        var id: String {
            return self.description
        }
        
        case fit
        case fill
        
        var description: String {
            switch self {
            case .fit: return "Fit"
            case .fill: return "Fill"
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
    @Published var selectedCollageContentMode: CollageContentMode? = .fit
    @Published var selectedBackgroundColor: Color = .black
        
    var maxNumberOfMedia: Int {
        
        let (rows, columns) = self.selectedCollageType.rowsAndColumns
        let base = rows * columns
        
        if self.selectedCollageType.isGrid { return base }
        
        switch self.selectedCollageType {
        case .oneLargeTwoSmall:   return base + 1   // 1x2 → 3
        case .oneLargeOneSmall:   return base + 1   // 1x1 → 2
        case .oneSmallOneLarge:   return base + 1   // 1x1 → 2
        case .twoLargeTwoSmall:   return base       // 2x2 → 4 (no extra)
        case .grid:               return base       // defensive, already handled
        }
        
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
        return self.isCreateContext ? "Create Collage" : "Collage"
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
    
    func save(image: UIImage?) {
        
        guard let client = self.client else { return }
        guard let image else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let _ = try await self.apiService
                    .uploadMedia(uploadMedia: .init(
                        data: image.compressedData(maxMegaBytes: 5) ?? Data(),
                        businessId: self.activeDestinationService.businessId,
                        locationId: client.locationId,
                        clientId: client.id,
                        mediaType: .collage
                    ))
                
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
                            message: Constants.Message.errorMessage(context: .create, "collage"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
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
