//
//  MediaPreviewViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/31/25.
//

import Combine
import Foundation

final class MediaPreviewViewModel: ViewModel {
    
    internal let loggerName: String = "MEDIA_PREVIEW_VIEW_MODEL"
    internal let loggerEmoji: String = "📸"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    @Published private(set) var media: [Media] = []
    @Published var selectedMedia: Media?
    private(set) var selectedMediaId: String = ""
    
    @Published var shouldShowTags: Bool = true
    @Published var shouldShowOptionsSheet: Bool = false

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    var isSingleMedia: Bool {
        self.media.count == 1
    }
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.alertService = alertService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        
        self.logInit()
        bindSubscribers()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(selectedMedia: Media?,
               media: [Media]) -> Self {
        
        self.selectedMedia = selectedMedia ?? media.first
        self.selectedMediaId = selectedMedia?.id ?? ""
        self.media = media
        
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func select(media: Media) {
        
        self.selectedMedia = media
        self.selectedMediaId = media.id
        
    }
    
    func favoriteMedia() {
        
        guard let selectedMedia else { return }
        
        Task { [weak self] in
            
            if selectedMedia.isFavorited {
                try await self?.apiService.unfavoriteMedia(mediaId: selectedMedia.id)
            } else {
                try await self?.apiService.favoriteMedia(mediaId: selectedMedia.id)
            }
            
            await MainActor.run { [weak self] in
                
                let isNowFavorited = !selectedMedia.isFavorited
                
                self?.showToast(
                    title: "Success!",
                    message: isNowFavorited ? "Media favorited." : "Media unfavorited.",
                    image: .systemImage("star.fill")
                )
                
                self?.selectedMedia?.isFavorited.toggle()
                self?.shouldShowOptionsSheet = false
                
            }
            
        }
        
    }
    
    func presentDeleteMediaAlert() {
        
        self.shouldShowOptionsSheet = false
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: Constants.Message.deleteConfirmationTitle("Media"),
                message: Constants.Message.deleteConfirmationMessage("media"),
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    self?.deleteMedia()
                },
                primaryButtonBackgroundColor: Style.shared.background(.error),
                primaryButtonTextColor: Style.shared.textColor(.titleInverted),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.quaternary),
                secondaryButtonTextColor: Style.shared.textColor(.title)
            ))))
        
    }
    
    func showMediaTagSheet() {
        
        guard let selectedMedia = self.selectedMedia else { return }
        
        self.shouldShowOptionsSheet = false
        
        self.navigationService?
            .modal(fullScreenCover: .mediaTags(
                selectedMedia: selectedMedia
            ))
        
    }
    
    private func reloadSelectedMedia() {
        
        guard let selectedMedia else { return }
        
        Task { [weak self] in
         
            let newMedia = try await self?.apiService.getMedia(id: selectedMedia.id)
            
            await MainActor.run { [weak self, newMedia] in
                
                guard let newMedia else { return }
                
                if let index = self?.media.firstIndex(where: { $0.id == selectedMedia.id }) {
                    
                    self?.media[index] = newMedia
                    self?.selectedMedia = newMedia
                    self?.selectedMediaId = newMedia.id
                    
                }
                
            }
            
        }
        
    }
    
    private func deleteMedia() {
        
        guard let selectedMedia else { return }
        
        Task { [weak self] in
            
            try await self?.apiService.deleteMedia(mediaId: selectedMedia.id)
            
            await MainActor.run { [weak self] in
                
                guard let self else { return }
                guard let idx = self.media.firstIndex(where: { $0.id == selectedMedia.id }) else { return }
                
                // If this was the only item, pop and remove it.
                if self.media.count == 1 {
                    
                    self.navigationService?.pop()
                    
                    self.media.remove(at: idx)
                    self.selectedMedia = nil
                    self.selectedMediaId = ""
                    
                    return
                    
                }
                
                // Prefer the next item; otherwise take the previous.
                let nextIndex = (idx < self.media.count - 1) ? idx + 1 : max(idx - 1, 0)
                let nextItem = self.media[nextIndex]
                
                // Remove the current item, then update selection.
                self.media.remove(at: idx)
                self.selectedMedia = nextItem
                self.selectedMediaId = nextItem.id
                
                showToast(
                    title: "Success",
                    message: "We were able to delete this media.",
                    image: .systemImage("trash.fill")
                )
                                
            }
            
        }
        
    }
    
    func showToast(title: String,
                           message: String,
                           image: ImageSource) {
        
        Task {
            
            await MainActor.run { [image]
                
                ToastManager.shared.present(
                    toastItem: .init(
                        title: title,
                        message: message,
                        backgroundColor: Style.shared.background(.primary),
                        image: image,
                        tint: Style.shared.accent,
                        isUserInteractionEnabled: true,
                        timing: .medium
                    )
                )
                
            }
            
        }
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.viewLifecycleService
            .publisher(for: .mediaPreview)
            .receiveOnMain()
            .sink { [weak self] in
                self?.reloadSelectedMedia()
            }
            .store(in: &self.cancelBag)
        
    }
    
}

extension MediaPreviewViewModel {
    
    func track() {
        self.analyticsService.track(screen: .media(.preview))
    }
    
}
