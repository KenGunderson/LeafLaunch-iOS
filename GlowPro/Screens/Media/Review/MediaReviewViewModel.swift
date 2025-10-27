//
//  MediaReviewViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/17/25.
//

import UIKit

final class MediaReviewViewModel: ViewModel {
    
    enum Context: Hashable {
        
        case location(locationId: String)
        case client(clientId: String)
        
        static func transformFromMediaContext(_ mediaContext: MediaContext) -> Self {
            switch mediaContext {
            case .location(locationId: let locationId): return .location(locationId: locationId)
            case .client(clientId: let clientId): return .client(clientId: clientId)
            default: fatalError("This context does not support business / employee")
            }
        }
        
    }
    
    internal let loggerName: String = "MEDIA_REVIEW_VIEW_MODEL"
    internal let loggerEmoji: String = "📸"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let mediaTransferService: MediaTransferServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    @Published private(set) var images: [MediaFusion] = []
    @Published var selectedImage: MediaFusion?
    private(set) var selectedImageId: String = ""

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    private var context: Context!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         mediaTransferService: MediaTransferServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.activeDestinationService = activeDestinationService
        self.mediaTransferService = mediaTransferService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        
        self.logInit()
        bindSubscribers()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(context: Context,
               images: [UIImage]) -> Self {
        
        self.context = context
        
        let mediaFusion = images.map { MediaFusion(kind: .uiImage($0), isUploaded: false )}
        
        self.images = mediaFusion
        self.selectedImage = mediaFusion.first
        
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func select(image: MediaFusion) {
        
        self.selectedImage = image
        self.selectedImageId = image.id
        
    }
    
    func create() {
                        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let businessId = self.activeDestinationService.businessId ?? ""
                var locationId = self.activeDestinationService.locationEmployee?.locationId ?? ""
                var clientId: String?
                
                switch self.context! {
                case .location(let contextLocationId): locationId = contextLocationId
                case .client(let contextClientId): clientId = contextClientId
                }
                
                _ = try await createAllMedia(
                    businessId: businessId,
                    locationId: locationId,
                    clientId: clientId
                )
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Media Saved Successfully!",
                        action: {
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                                self.navigationService?.popLast(count: 2)
                            }
                            
                        }
                    ))))
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .create, "media"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }
    
    func deleteMediaFusion(_ mediaFusionId: String) {
                
        self.images.removeAll(where: { $0.id == mediaFusionId })
        
        if self.images.isEmpty {
            
            self.navigationService?.pop()
            return
            
        }
        
        self.selectedImage = self.images.first
        self.selectedImageId = self.selectedImage?.id ?? ""
        
    }
    
    private func createAllMedia(businessId: String,
                                locationId: String,
                                clientId: String?) async throws {
        
        let mediaToUpload = self.images.filter({ $0.isUploaded == false })
        var uploadedURLs: [URL] = []
        
        try await mediaToUpload.asyncForEach { media in
            
            switch media.kind {
            case .uiImage(let image):
                
                let newURL = try await self.apiService
                    .uploadMedia(uploadMedia: .init(
                        data: image.compressedData(maxMegaBytes: 5) ?? Data(),
                        businessId: businessId,
                        locationId: locationId,
                        clientId: clientId
                    ))
                
                uploadedURLs.append(URL(string: newURL)!)
                
            case .pdf(let image):
                
                let newURL = try await self.apiService
                    .uploadMedia(uploadMedia: .init(
                        data: image.compressedData(maxMegaBytes: 5) ?? Data(),
                        businessId: businessId,
                        locationId: locationId,
                        clientId: clientId,
                        mediaType: .diagram
                    ))
                
                uploadedURLs.append(URL(string: newURL)!)
                
            case .url: print("Not Needed")
            }
            
        }
        
        self.mediaTransferService
            .sendURLs(uploadedURLs)
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension MediaReviewViewModel {
    
    func track() {
        self.analyticsService.track(screen: .media(.mediaReview))
    }
    
}
