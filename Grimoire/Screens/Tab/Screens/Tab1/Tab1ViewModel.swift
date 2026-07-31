//
//  TabBar1ViewModel.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/23/25.
//

import Foundation

final class Tab1ViewModel: ViewModel {
    
    internal let loggerName: String = "TAB_1_VIEW_MODEL"
    internal let loggerEmoji: String = "🔹"
    
    private let alertService: AlertServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let userDefaultsService: UserDefaultsServiceProtocol
    
    private var tabBarNavigationService: TabBarNavigationService?
    private var cancelBag: CancelBag!
    private var logoutTask: Task<Void, Never>?

    @Published private(set) var projects: [String] = []
    
    init(alertService: AlertServiceProtocol,
         authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         userDefaultsService: UserDefaultsServiceProtocol) {
        
        self.alertService = alertService
        self.authService = authService
        self.analyticsService = analyticsService
        self.userDefaultsService = userDefaultsService
        
        self.logInit()
        
    }
    
    isolated deinit {
        
        cancelTasks()
        self.logDeinit()
        
    }
    
    func setup(tabBarNavigationService: TabBarNavigationService) {
        self.tabBarNavigationService = tabBarNavigationService
    }
    
    func loadData(showHud: Bool = false) {
        
    }

    var shouldShowEmptyState: Bool {
        self.projects.isEmpty
    }

    var hasProjects: Bool {
        !self.projects.isEmpty
    }

    func createProject() {

        let projectNumber = self.projects.count + 1

        self.projects.append("Example Project \(projectNumber)")

    }

    func remove(project: String) {

        self.projects.removeAll { $0 == project }

    }
    
    func logout() {
        
        self.logoutTask?.cancel()
        
        let authService = self.authService
        
        self.logoutTask = Task {
            
            do {
                try await authService.logout()
            }
            catch {
                guard !Task.isCancelled else { return }
            }
            
        }
        
    }
    
    func setRandomTheme() {
        
        self.userDefaultsService
            .set(theme: AvailableTheme.allCases.randomElement()!)
        
    }
    
    func presentAlert() {
        
        self.alertService
            .showAlert(.init(.appAlert(.success(message: "Test", action: {
                
            }))))
        
    }
    
    private func cancelTasks() {
        self.logoutTask?.cancel()
    }
    
}

extension Tab1ViewModel {
    
    func track() {
        self.analyticsService.track(screen: .main(.tabIntent(tab: .tab1)))
    }
    
}
