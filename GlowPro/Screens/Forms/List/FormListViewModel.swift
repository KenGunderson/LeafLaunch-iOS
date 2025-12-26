//
//  FormListViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/6/25.
//

import Foundation
import PDFKit

final class FormListViewModel: ViewModel {
    
    enum Context: Sendable {
        
        case business(businessId: String)
        case location(locationId: String)
        
        var analyticsName: String {
            switch self {
            case .business: return "business"
            case .location: return "location"
            }
        }
        
        var isLocationContext: Bool {
            switch self {
            case .business: return false
            case .location: return true
            }
        }
        
    }
    
    enum Mode: Sendable, Hashable {
        
        
        case preview
        case singleSelection(completion: @Sendable (Form) -> Void)
        
        var analyticsName: String {
            switch self {
            case .preview: return "preview"
            case .singleSelection: return "single_selection"
            }
        }
        
        static func == (lhs: FormListViewModel.Mode, rhs: FormListViewModel.Mode) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            
            switch self {
            case .preview: hasher.combine(0)
            case .singleSelection: hasher.combine(1)
            }
            
        }
        
    }
    
    internal let loggerName: String = "FORM_LIST_VIEW_MODEL"
    internal let loggerEmoji: String = "📜"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var forms: [Form] = []
    
    private(set) var context: Context!
    private(set) var mode: Mode!
    
    var isOwnerOrManager: Bool {
        return self.activeDestinationService.isOwnerOrManager
    }
    
    var shouldShowAddButton: Bool {
        return self.isOwnerOrManager
    }
    
    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         activeDestinationService: ActiveDestinationServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol) {
        
        self.apiService = apiService
        self.authService = authService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.activeDestinationService = activeDestinationService
        self.userDefaultsService = userDefaultsService
        self.viewLifecycleService = viewLifecycleService
        
        self.logInit()
        self.bindSubscribers()
        
    }
    
    deinit {
        self.logDeinit()
    }
    
    @discardableResult
    func setup(context: Context,
               mode: Mode) -> Self {
        
        self.context = context
        self.mode = mode
        
        return self
        
    }
    
    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }
    
    func loadData(showHud: Bool = true) {
        
        if showHud {
            
            self.alertService
                .showAlert(.init(.simpleLoadingIndicator))
            
        }
        
        Task {
            
            do {
                
                var forms: [Form] = []
                
                switch self.context! {
                case .business(let businessId):
                    
                    forms = try await self.apiService
                        .getForms(businessId: businessId)
                    
                case .location(let locationId):
                   
                    forms = try await self.apiService
                        .getForms(locationId: locationId)
                
                }
                
                await MainActor.run { [weak self, forms] in
                    self?.forms = forms
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("forms"),
                            action: {
                                
                                self.navigationService?
                                    .popWithDelay()
                                
                            })
                    ))
                )
                
            }
            
            if showHud {
                
                self.alertService
                    .dismissLoadingIndicator()
                
            }
            
        }
        
    }
    
    func selectForm(_ form: Form) {
        
        switch self.mode! {
        case .preview:
            
            if let document = PDFDocument(url: form.mediaURL) {
                
                self.navigationService?
                    .modal(fullScreenCover: .annotation(
                        kind: .pdf(document),
                        isReadOnly: true,
                        completion: { _ in }))
                
            } else {
                
                self.navigationService?
                    .modal(fullScreenCover: .mediaPreview(context: .url(url: form.mediaURL)))
                
            }
            
        case .singleSelection(let completion):
            
            completion(form)
            self.navigationService?.pop()
            
        }
        
    }
    
    func handleUploadURLResult(_ result: Result<[URL], Error>) {
        
        switch result {
        case .success(let urls):
            
            guard let fileURL = urls.first else {
                return
            }
            
            // Make sure it's a PDF (defensive, even if fileImporter filters)
            guard fileURL.pathExtension.lowercased() == "pdf" else {
                
                presentWrongFileTypeAlert()
                return
                
            }
            
            // Required for security-scoped URLs (File Provider / iCloud, etc.)
            guard fileURL.startAccessingSecurityScopedResource() else {
                
                let error = NSError(
                    domain: "PDFImport",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Unable to access imported file."]
                )
                
                self.showError(error: error)
                return
                
            }
            
            defer {
                fileURL.stopAccessingSecurityScopedResource()
            }
            
            let localURL: URL
            
            do {
                
                localURL = try self.persistImportedFile(at: fileURL)
                
            } catch {
                
                self.showError(error: error)
                return
                
            }
            
            switch self.context! {
            case .business:
                return
                
            case .location:
                
                self.navigationService?
                    .push(.form(.formCreateEdit(
                        formId: nil,
                        mediaURL: localURL
                    )))
                
            }
            
        case .failure(let error):
            self.showError(error: error)
        }
        
    }
    
    private func persistImportedFile(at url: URL) throws -> URL {
        
        let fileManager = FileManager.default
        
        let destinationURL = fileManager
            .temporaryDirectory
            .appendingPathComponent(url.lastPathComponent)
        
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        try fileManager.copyItem(at: url, to: destinationURL)
        
        return destinationURL
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    private func showError(error: Error) {
        
        self.alertService
            .showAlert(.init(.appAlert(.error(
                message: error.localizedDescription,
                action: {
                    
                    
                }))))
        
    }
    
    private func bindSubscribers() {
        
        self.cancelBag = CancelBag()
        
        self.viewLifecycleService
            .publisher(for: .formList)
            .sink { [weak self] in
                
                self?.loadData(showHud: false)
                
            }
            .store(in: &self.cancelBag)
        
    }
    
    private func presentWrongFileTypeAlert() {
        
        self.alertService.showAlert(.init(
            .appAlert(
                .error(
                    message: "The file type you selected was not a PDF. We only support PDF files. Please select a different file.",
                    action: {  })
            ))
        )
        
    }
    
}

extension FormListViewModel {
    
    func track() {
        
        self.analyticsService.track(screen: .form(.formList(
            context: self.context,
            mode: self.mode
        )))
        
    }
    
}
