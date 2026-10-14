//
//  LegalViewModel.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 1/23/25.
//

import SwiftUI
import Combine

final class LegalViewModel: ViewModel {

    internal let loggerName: String = "LEGAL_VIEW_MODEL"
    internal let loggerEmoji: String = "⚙️"

    enum Context {

        case termsAndConditions
        case privacyPolicy
        case subscriptionTerms

        var displayName: String {

            switch self {
            case .termsAndConditions: return "Terms and Conditions"
            case .privacyPolicy: return "Privacy Policy"
            case .subscriptionTerms: return "Subscription Terms"
            }

        }

        var dataName: String {

            switch self {
            case .termsAndConditions: return "terms_of_service"
            case .privacyPolicy: return "privacy_policy"
            case .subscriptionTerms: return "subscription"
            }

        }


    }

    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let environmentService: EnvironmentServiceProtocol

    private(set) var context: Context!
    private weak var navigationService: NavigationService?

    private var cancelBag: CancelBag!

    @Published private(set) var legalItems: [LegalItem] = []

    init(apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         environmentService: EnvironmentServiceProtocol) {

        self.apiService = apiService
        self.analyticsService = analyticsService
        self.alertService = alertService
        self.authService = authService
        self.viewLifecycleService = viewLifecycleService
        self.environmentService = environmentService

    }

    @discardableResult
    func setup(context: Context) -> Self {

        self.context = context
        return self

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {

        track()
        bindSubscribers()

    }

    func loadData() {

//        self.alertService
//            .showAlert(.init(.simpleLoadingIndicator))
//
//        Task {
//
//            do {
//
//                let legalItems = try await self.apiService
//                    .getLegalInformation(context: self.context.dataName)
//
//                await MainActor.run { [weak self] in
//
//                    self?.legalItems = [
//                        .init(title: "Test", sections: [
//                            "This is a cool one",
//                            "This is another cool one"
//                        ])
//
//                    ]
//                }
//
//            }
//            catch {
//
//                self.alertService.showAlert(.init(
//                    .appAlert(
//                        .error(
//                            message: Constants.Message.errorMessage("legal information"),
//                            action: {
//
//                                self.navigationService?
//                                    .popWithDelay()
//
//                            })
//                    ))
//                )
//
//            }
//
//            self.alertService
//                .dismissLoadingIndicator()
//
//        }

    }

    func dismiss() {

        self.navigationService?
            .pop()

    }

    private func bindSubscribers() {
        self.cancelBag = CancelBag()
    }

}

extension LegalViewModel {

    func track() {
        self.analyticsService.track(screen: .settings(.legal(context: self.context.dataName)))
    }

}
