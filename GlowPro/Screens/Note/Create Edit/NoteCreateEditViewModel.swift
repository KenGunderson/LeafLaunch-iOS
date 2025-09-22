//
//  NoteCreateEditViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/13/25.
//

import SwiftUI
import _PhotosUI_SwiftUI

final class NoteCreateEditViewModel: ViewModel {
    
    enum Context: Hashable {
        
        case create
        case update(noteId: String)
        
        var noteID: String? {
            
            switch self {
            case .update(noteId: let noteID): return noteID
            default: return nil
            }
            
        }
        
    }
    
    internal let loggerName: String = "NOTE_CREATE_EDIT_VIEW_MODEL"
    internal let loggerEmoji: String = "📝"
    
    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let authService: AuthServiceProtocol
    private let alertService: AlertServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let mediaTransferService: MediaTransferServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    
    @Published var title: String = ""
    @Published var message: String = ""
    @Published var employeeSignature: String = ""
    
    @Published var mediaFusion: [MediaFusion] = []
    @Published var selectedPhotoPickerItems: [PhotosPickerItem] = []
    
    @Published var shouldShowMediaSourceSelectionSheet: Bool = false
    @Published var shouldShowApplePhotosSelectionSheet: Bool = false
    
    private var context: Context!
    private var clientId: String!
    
    private var cancelBag: CancelBag!
    
    var navTitle: String {
        return self.context == .create ? "Create Note" : "Edit Note"
    }
    
    var isEditContext: Bool {
        return self.context != .create
    }
    
    var isOwnerOrManager: Bool {
        return self.activeDestinationService.isOwnerOrManager
    }
    
    var saveButtonTitle: String {
        return self.context == .create ? "Create" : "Update"
    }
    
    var isSaveButtonEnabled: Bool {
        
        return (
            !self.title.isEmpty &&
            !self.message.isEmpty &&
            !employeeSignature.isEmpty
        )
        
    }
    
    var currentEmployeeName: String {
        return self.activeDestinationService.locationEmployee?.user.fullName ?? ""
    }
    
    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         mediaTransferService: MediaTransferServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.authService = authService
        self.alertService = alertService
        self.activeDestinationService = activeDestinationService
        self.mediaTransferService = mediaTransferService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService
        
        bindSubscribers()
        self.logInit()
        
    }
    
    @discardableResult
    func setup(context: Context,
               clientId: String) -> Self {
        
        self.context = context
        self.clientId = clientId
        
        return self
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func loadData() {
        
        self.employeeSignature = self.currentEmployeeName
        
        guard self.isEditContext else { return }
        guard let noteId = self.context.noteID else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let note = try await self.apiService
                    .getNote(id: noteId)
                
                await MainActor.run {
                    
                    self.title = note.title
                    self.message = note.message
                    self.employeeSignature = note.employeeSignature ?? self.currentEmployeeName
                    
                    if self.mediaFusion.isEmpty {
                        
                        self.mediaFusion = note.mediaURLs.map { .init(
                            id: $0.absoluteString,
                            kind: .url($0),
                            isUploaded: true
                        )}
                        
                    }
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("note"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }
    
    func saveOrUpdate() {
        
        if self.context == .create {
            create()
        } else {
            update()
        }
        
    }
    
    func handleSourceSelectionAction(_ source: SourceType) {
        
        switch source {
        case .applePhotos: self.shouldShowApplePhotosSelectionSheet = true
        case .gallery:
            
            self.navigationService?
                .push(.media(.gallery(
                    mediaContext: .client(clientId: self.clientId),
                    mediaSelectionContext: .singleSelection(completion: { [weak self] media in
                        
                        guard let media else { return }
                        
                        self?.mediaFusion.append(.init(
                            kind: .url(media.url),
                            isUploaded: false
                        ))
                        
                    })
                )))
            
        case .camera:
            
            self.navigationService?
                .push(.media(.camera(
                    context: .client(clientId: self.clientId),
                    mode: .single(nil))
                ))
            
        }
        
    }
    
    func handlePHPickerSelectionConverionToUIImage(items: [PhotosPickerItem]) {
                        
        Task {
            
            await items.asyncForEach { item in
                
                if let data = try? await item.loadTransferable(type: Data.self) {
                    
                    if let uiImage = UIImage(data: data) {
                        
                        await MainActor.run {
                            
                            self.mediaFusion.append(.init(
                                kind: .uiImage(uiImage),
                                isUploaded: false
                            ))
                            
                            self.selectedPhotoPickerItems = []
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
        
    func deleteMediaFusion(id: String) {
        self.mediaFusion.removeAll(where: { $0.id == id })
    }
    
    func presentDeleteNoteAlert() {
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: Constants.Message.deleteConfirmationTitle("Note"),
                message: Constants.Message.deleteConfirmationMessage("Note"),
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    self?.delete()
                },
                primaryButtonBackgroundColor: Style.shared.background(.error),
                primaryButtonTextColor: Style.shared.textColor(.titleInverted),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.quaternary),
                secondaryButtonTextColor: Style.shared.textColor(.title)
            ))))
        
    }
    
    private func delete() {
        
        guard let noteId = self.context.noteID else { return }
        
        Task {
            
            do {
                
                try await self.apiService
                    .deleteNote(id: noteId)
                
                await MainActor.run { [weak self] in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self?.navigationService?.pop()
                    }
                    
                }
                
            }
            catch {
                
                self.alertService
                    .showAlert(.init(.appAlert(.error(
                        message: Constants.Message.errorMessage(context: .delete, "note"),
                        action: {})
                    )))
                
            }
            
        }
        
    }
    
    private func create() {
        
        guard let authUser = self.authService.currentUser else { return }
                
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                var employeeId = self.activeDestinationService.locationEmployee?.employeeId
                
                if employeeId == nil {
                    
                    let client = try await self.apiService
                        .getClient(id: self.clientId)
                    
                    employeeId = try await self.apiService
                        .getEmployeeByUserIdForLocation(
                            userId: authUser.id,
                            locationId: client.locationId ?? ""
                        )
                    
                }
                
                let allURLs = try await uploadAndConstructUrlsIfNeeded()
                
                let note = Note(
                    id: "",
                    clientId: self.clientId,
                    employeeId: employeeId ?? "",
                    title: self.title,
                    message: self.message,
                    employeeSignature: self.employeeSignature,
                    mediaURLs: allURLs,
                    createdAt: ""
                )
                
                _ = try await self.apiService
                    .createNote(note: note)
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Note Created Successfully!",
                        action: {
                            self.navigationService?.popWithDelay()
                        }
                    ))))
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .create, "note"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }
    
    private func update() {
        
        guard let authUser = self.authService.currentUser else { return }
        guard let noteId = self.context.noteID else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                var employeeId = self.activeDestinationService.locationEmployee?.employeeId
                
                if employeeId == nil {
                    
                    let client = try await self.apiService
                        .getClient(id: self.clientId)
                    
                    employeeId = try await self.apiService
                        .getEmployeeByUserIdForLocation(
                            userId: authUser.id,
                            locationId: client.locationId ?? ""
                        )
                    
                }
                
                let allURLs = try await uploadAndConstructUrlsIfNeeded()
                
                let note = Note(
                    id: noteId,
                    clientId: self.clientId,
                    employeeId: employeeId ?? "",
                    title: self.title,
                    message: self.message,
                    employeeSignature: self.employeeSignature,
                    mediaURLs: allURLs,
                    createdAt: ""
                )
                
                _ = try await self.apiService
                    .updateNote(note: note)
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Note Updated Successfully!",
                        action: {
                            self.navigationService?.popWithDelay()
                        }
                    ))))
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage(context: .update, "note"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }
    
    private func uploadAndConstructUrlsIfNeeded() async throws -> [URL] {
        
        let mediaToUpload = self.mediaFusion.filter({ $0.isUploaded == false })
        var newMediaURLs: [URL?] = []
        
        try await mediaToUpload.asyncForEach { media in
            
            switch media.kind {
            case .uiImage(let image):
                
                let newURL = try await self.apiService
                    .uploadMedia(uploadMedia: .init(
                        data: image.compressedData(maxMegaBytes: 5) ?? Data(),
                        businessId: self.activeDestinationService.businessId,
                        locationId: self.activeDestinationService.locationEmployee?.locationId ?? "",
                        clientId: self.clientId
                    ))
                
                newMediaURLs.append(URL(string: newURL))
                
            case .url(let url):
                
                newMediaURLs.append(url)
            }
            
        }
        
        var allURLs = self.mediaFusion.filter({ $0.isUploaded }).compactMap { $0.kind.url }
        allURLs += newMediaURLs.compactMap({ $0 })
        
        return allURLs
        
    }
    
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.mediaTransferService
            .mediaURLsPublisher
            .receiveOnMain()
            .sink { [weak self] urls in
                
                let newMediaFusion = urls.map({
                    
                    MediaFusion(
                        kind: .url($0),
                        isUploaded: true
                    )
                    
                })
                
                self?.mediaFusion
                    .append(contentsOf: newMediaFusion)
                
            }
            .store(in: &self.cancelBag)
        
    }
    
}

extension NoteCreateEditViewModel {
    
    func track() {
        
        self.analyticsService
            .track(screen: .note(.createEdit(
                context: self.context,
                clientId: self.clientId
            )))
        
    }
    
}
