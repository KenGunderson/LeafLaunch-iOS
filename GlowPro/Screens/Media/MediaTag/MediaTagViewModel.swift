//
//  MediaTagViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/3/25.
//

import Combine
import Foundation

final class MediaTagViewModel: ViewModel {
    
    internal let loggerName: String = "MEDIA_TAG_VIEW_MODEL"
    internal let loggerEmoji: String = "📸"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    @Published private(set) var mediaTags: [MediaTag] = []
    @Published var newMediaTag: String = ""
    
    var isNewMediaTagValid: Bool {
        
        guard !newMediaTag.isEmpty else { return false }
        
        let trimmedNewMediaTag = newMediaTag.trimmed()
        return !trimmedNewMediaTag.isEmpty
        
    }
    
    private(set) var selectedMedia: Media?

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
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
    func setup(media: Media?) -> Self {
        
        self.selectedMedia = media
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData() {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let mediaTags = try await self.apiService
                    .getMediaTags(businessId: self.activeDestinationService.businessId ?? "")
                
                await MainActor.run { [weak self] in
                    self?.mediaTags = mediaTags
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("media tags"),
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
    
    func createMediaTag() {
        
        guard self.isNewMediaTagValid else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let trimmedNewMediaTag = self.newMediaTag.trimmed()
                
                try await self.apiService.createTag(
                    tag: trimmedNewMediaTag,
                    businessId: self.activeDestinationService.businessId ?? ""
                )
                
                if selectedMedia != nil {
                    
                    let mediaTags = try await self.apiService
                        .getMediaTags(businessId: self.activeDestinationService.businessId ?? "")
                    
                    if let tag = mediaTags.first(where: { $0.name == trimmedNewMediaTag }) {
                        addOrDeleteMediaTagForMedia(tag)
                    }
                    
                }
                
                await MainActor.run { [weak self] in
                    self?.newMediaTag = ""
                }
                
                loadData()
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .create, "media tags"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService
                .dismissLoadingIndicator()
            
        }
        
    }
    
    func addOrDeleteMediaTagForMedia(_ mediaTag: MediaTag) {
        
        if self.selectedMedia?.tags.contains(mediaTag) ?? false {
            deleteMediaTagForMedia(mediaTag)
        } else {
            addMediaTagForMedia(mediaTag)
        }
        
    }
    
    func presentMediaTagAlert(mediaTag: MediaTag) {
                
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: Constants.Message.deleteConfirmationTitle("Media Tag"),
                message: Constants.Message.deleteConfirmationMessage("media tag"),
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    
                    self?.deleteMediaTag(mediaTag: mediaTag)
                    
                },
                primaryButtonBackgroundColor: Style.shared.background(.error),
                primaryButtonTextColor: Style.shared.textColor(.titleInverted),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.quaternary),
                secondaryButtonTextColor: Style.shared.textColor(.title)
            ))))
        
    }
    
    private func deleteMediaTag(mediaTag: MediaTag) {
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                try await self.apiService.deleteTag(mediaTagId: mediaTag.id)
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .delete, "media tags"),
                            action: {})
                    ))
                )
                
            }
            
            self.viewLifecycleService
                .reload(for: .mediaPreview)
            
            self.alertService
                .dismissLoadingIndicator()
            
            loadData()
            
        }
        
    }
    
    private func addMediaTagForMedia(_ mediaTag: MediaTag) {
        
        guard let selectedMedia else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                try await self.apiService.createMediaTagForMedia(
                    mediaId: selectedMedia.id,
                    mediaTagId: mediaTag.id
                )
                
                await MainActor.run { [weak self] in
                    self?.selectedMedia?.tags.append(mediaTag)
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .update, "media tags"),
                            action: {})
                    ))
                )
                
            }
            
            self.viewLifecycleService
                .reload(for: .mediaPreview)
            
            self.alertService
                .dismissLoadingIndicator()
            
            loadData()
            
        }
        
    }
    
    private func deleteMediaTagForMedia(_ mediaTag: MediaTag) {
        
        guard let selectedMedia else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                try await self.apiService.deleteMediaTagFromMedia(
                    mediaId: selectedMedia.id,
                    mediaTagId: mediaTag.id
                )
                
                await MainActor.run { [weak self] in
                    self?.selectedMedia?.tags.removeAll(where: { $0.id == mediaTag.id })
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .delete, "media tags"),
                            action: {})
                    ))
                )
                
            }
            
            self.viewLifecycleService
                .reload(for: .mediaPreview)
            
            self.alertService
                .dismissLoadingIndicator()
            
            loadData()
            
        }
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension MediaTagViewModel {
    
    func track() {
        self.analyticsService.track(screen: .media(.mediaTags))
    }
    
}
