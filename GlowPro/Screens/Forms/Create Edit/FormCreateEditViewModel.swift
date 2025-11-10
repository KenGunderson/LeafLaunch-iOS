//
//  FormCreateEditViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/7/25.
//

import Combine
import Foundation

final class FormCreateEditViewModel: ViewModel {
    
    internal let loggerName: String = "FORM_CREATE_EDIT_VIEW_MODEL"
    internal let loggerEmoji: String = "📜"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private(set) var alertService: AlertServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    @Published private(set) var business: Business?
    
    @Published var title: String = ""
    
    var isSaveButtonEnabled: Bool {
        return (!self.title.isEmpty)
    }
    
    private var formId: String?
    private(set) var url: URL?

    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    var isCreateContext: Bool {
        return self.formId == nil
    }
    
    var navTitle: String {
        return self.formId == nil ? "Create Form" : "Edit Client"
    }
    
    var saveButtonTitle: String {
        return self.formId == nil ? "Create" : "Save"
    }
    
    var isOwnerOrManager: Bool {
        return self.activeDestinationService.isOwnerOrManager
    }
    
    var showDeleteButton: Bool {
        return self.isOwnerOrManager && self.formId != nil
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
    func setup(formId: String? = nil,
               url: URL?) -> Self {
        
        self.formId = formId
        self.url = url
        
        return self
        
    }
    
    func loadData() {
        
        guard let formId else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let form = try await self.apiService.getForm(formId: formId)
                
                await MainActor.run {
                    
                    self.title = form.title
                    self.url = form.mediaURL
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("form"),
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
    
    func formatPhoneNumber(_ input: String) -> String {
        return input.formatted(.phone(defaultCountryCode: nil))
    }
    
    func saveOrUpdate() {
        
        if self.formId == nil {
            save()
        } else {
            update()
        }
        
    }
    
    private func save() {
        
        guard let mediaURL = self.url else { return }
        
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let (data, _) = try await URLSession.shared.data(from: mediaURL)
                
                let createdURL = try await self.apiService.uploadMedia(
                    uploadMedia: .init(
                        data: data,
                        businessId: self.activeDestinationService.businessId ?? "",
                        locationId: self.activeDestinationService.locationEmployee?.locationId ?? "",
                        clientId: nil,
                        mediaType: .diagram,
                        contentType: .pdf
                    )
                )
                
                let newForm = Form(
                    id: UUID().uuidString,
                    locationId: self.activeDestinationService.locationEmployee?.locationId ?? "",
                    title: self.title,
                    mediaURL: URL(string: createdURL)!
                )
                
                try await self.apiService
                    .createForm(form: newForm)
                
                self.viewLifecycleService
                    .reload(for: .formList)
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Form created successfully.",
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
                            message: Constants.Message.errorMessage(context: .create, "form"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }
    
    private func update() {
        
        guard let formId else { return }
        guard let mediaURL = self.url else { return }
    
        self.alertService
            .showAlert(.init(.simpleLoadingIndicator))
        
        Task {
            
            do {
                
                let updatedForm = Form(
                    id: formId,
                    locationId: self.activeDestinationService.locationEmployee?.locationId ?? "",
                    title: self.title,
                    mediaURL: mediaURL
                )
                
                try await self.apiService
                    .updateForm(form: updatedForm)
                
                self.viewLifecycleService
                    .reload(for: .formList)
                
                self.alertService
                    .showAlert(.init(.appAlert(.success(
                        message: "Form updated successfully.",
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
                            message: Constants.Message.errorMessage(context: .update, "form"),
                            action: {})
                    ))
                )
                
            }
            
            self.alertService.dismissLoadingIndicator()
            
        }
        
    }
    
    func presentDeleteFormAlert() {
        
        self.alertService
            .showAlert(.init(.appAlert(.init(
                title: Constants.Message.deleteConfirmationTitle("Form"),
                message: Constants.Message.deleteConfirmationMessage("form"),
                primaryButtonTitle: "Yes",
                primaryButtonAction: { [weak self] in
                    self?.deleteForm()
                },
                primaryButtonBackgroundColor: Style.shared.background(.error),
                primaryButtonTextColor: Style.shared.textColor(.titleInverted),
                secondaryButtonTitle: "No",
                secondaryButtonAction: {},
                secondaryButtonBackgroundColor: Style.shared.background(.quaternary),
                secondaryButtonTextColor: Style.shared.textColor(.title)
            ))))
        
    }
    
    private func deleteForm() {
        
        Task {
            
            do {
                
                try await self.apiService
                    .deleteForm(id: self.formId ?? "")
                
                await MainActor.run { [weak self] in
                    
                    self?.viewLifecycleService
                        .reload(for: .formList)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self?.navigationService?.pop()
                    }
                    
                }
                
            }
            catch {
                
                self.alertService
                    .showAlert(.init(.appAlert(.error(
                        message: Constants.Message.errorMessage(context: .delete, "form"),
                        action: {})
                    )))
                
            }
            
        }
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension FormCreateEditViewModel {
    
    func track() {
        
        self.analyticsService.track(
            screen: .form(.formCreateEdit(formId: self.formId))
        )
        
    }
    
}
