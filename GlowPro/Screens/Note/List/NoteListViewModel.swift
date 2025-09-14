//
//  NoteListViewModel.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/13/25.
//

import Foundation

final class NoteListViewModel: ViewModel {
    
    internal let loggerName: String = "NOTE_LIST_VIEW_MODEL"
    internal let loggerEmoji: String = "📝"
    
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol
    private let activeDestinationService: ActiveDestinationServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    
    private var navigationService: NavigationService?
    private var cancelBag: CancelBag!
    
    @Published private(set) var notes: [Note] = []
    @Published private(set) var shouldShowEmptyState: Bool = false
    
    private(set) var clientId: String!
    
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
    func setup(clientId: String) -> Self {
        
        self.clientId = clientId
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
                
                let notes = try await self.apiService
                    .getNotes(clientId: self.clientId)
                
                await MainActor.run { [weak self, notes] in
                    
                    self?.notes = notes
                    self?.shouldShowEmptyState = notes.isEmpty
                    
                }
                
            }
            catch {
                
                self.alertService.showAlert(.init(
                    .appAlert(
                        .error(
                            message: Constants.Message.errorMessage("notes"),
                            action: {
                                
                                self.navigationService?
                                    .pop()
                                
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
    
    func selectClient(_ client: Client) {
        
        self.navigationService?
            .push(.client(.clientHome(clientId: client.id)))
        
    }
    
    func dismiss() {
        
        self.navigationService?
            .pop()
        
    }
    
    func emptyStateConfig() -> EmptyStateConfig {
        
        return .init(
            title: "No Notes Found",
            message: "Adding notes will help you keep track of your clients and their progress.",
            image: .systemImage("magnifyingglass"),
            actionTitle: "Add Your First Note",
            action: { [weak self] in
                
                self?.navigationService?
                    .push(
                        .note(.noteCreateEdit(
                            context: .create,
                            clientId: self?.clientId ?? ""
                        ))
                    )
                
            })
        
    }
    
    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }
    
}

extension NoteListViewModel {
    
    func track() {
        self.analyticsService.track(screen: .note(.noteList(clientId: self.clientId)))
    }
    
}
