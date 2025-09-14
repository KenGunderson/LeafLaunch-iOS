//
//  NoteCreateEditViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/13/25.
//

import SwiftUI

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
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    
    private var navigationService: NavigationService?
    
    @Published var title: String = ""
    @Published var message: String = ""
    
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
        return !self.title.isEmpty && !self.message.isEmpty
    }
    
    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         authService: AuthServiceProtocol,
         alertService: AlertServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {
        
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.authService = authService
        self.alertService = alertService
        self.activeDestinationService = activeDestinationService
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
                            userId: self.authService.currentUser?.id ?? "",
                            locationId: client.locationId ?? ""
                        )
                    
                }
                
                let note = Note(
                    id: "",
                    clientId: self.clientId,
                    employeeId: employeeId ?? "",
                    title: self.title,
                    message: self.message,
                    createdAt: ""
                )
                
                _ = try await self.apiService
                    .createNote(note: note)
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Note Created Successfully!",
                        action: {
                            self.navigationService?.pop()
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
                            userId: self.authService.currentUser?.id ?? "",
                            locationId: client.locationId ?? ""
                        )
                    
                }
                
                let note = Note(
                    id: noteId,
                    clientId: self.clientId,
                    employeeId: employeeId ?? "",
                    title: self.title,
                    message: self.message,
                    createdAt: ""
                )
                
                _ = try await self.apiService
                    .updateNote(note: note)
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Note Updated Successfully!",
                        action: {
                            self.navigationService?.pop()
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
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
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
