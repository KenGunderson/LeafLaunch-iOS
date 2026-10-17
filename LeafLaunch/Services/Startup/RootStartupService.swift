//
//  RootStartupCoordinator.swift
//  LeafLaunch
//
//  Created by Sako Hovaguimian on 2/16/26.
//

import SwiftUI

final class RootStartupService: RootStartupServiceProtocol, Loggable {

    internal let loggerName: String = "ROOT_STARTUP_SERVICE"
    internal let loggerEmoji: String = "🚀"

    private let launchService: LaunchScreenServiceProtocol
    private let environmentService: EnvironmentServiceProtocol
    private let apiService: APIServiceProtocol
    private let authService: AuthServiceProtocol
    private let firebaseService: FirebaseServiceProtocol
    private let appDelegateService: AppDelegateServiceProtocol
    private let connectivityService: ConnectivityServiceProtocol
    private let viewLifecycleService: ViewLifecycleServiceProtocol
    private let storeSessionService: StoreSessionServiceProtocol

    private var cancelBag: CancelBag!
    private var foregroundUserRefreshTask: Task<Void, Never>?
    private var registerDeviceTokenTask: Task<Void, Never>?
    private var deviceRegistrationId: UUID?
    private var healthCheckTask: Task<Void, Never>?
    private var storeBootstrapTask: Task<Void, Never>?
    private var hasStarted: Bool = false
    private var isSplashAnimationCompleted: Bool = false
    private var isAuthBootstrapCompleted: Bool = false
    private var hasResolvedLaunchGate: Bool = false
    private var didResolveInitialAuthState: Bool = false
    private var wasLoggedInAtStartup: Bool = false
    private var hasStartedStoreBootstrap: Bool = false
    private var isStoreBootstrapCompleted: Bool = false

    init(launchService: LaunchScreenServiceProtocol,
         environmentService: EnvironmentServiceProtocol,
         apiService: APIServiceProtocol,
         authService: AuthServiceProtocol,
         firebaseService: FirebaseServiceProtocol,
         appDelegateService: AppDelegateServiceProtocol,
         connectivityService: ConnectivityServiceProtocol,
         viewLifecycleService: ViewLifecycleServiceProtocol,
         storeSessionService: StoreSessionServiceProtocol) {

        self.launchService = launchService
        self.environmentService = environmentService
        self.apiService = apiService
        self.authService = authService
        self.firebaseService = firebaseService
        self.appDelegateService = appDelegateService
        self.connectivityService = connectivityService
        self.viewLifecycleService = viewLifecycleService
        self.storeSessionService = storeSessionService

        self.logInit()

    }

    var isProduction: Bool {
        return self.environmentService.environment == .production
    }

    isolated deinit {

        cancelTasks()
        self.logDeinit()

    }

    func setup(appDelegate: AppDelegate) {

        self.appDelegateService
            .setup(appDelegate: appDelegate)

    }

    func setLaunchState(_ state: LaunchScreenService.State) {

        self.launchService
            .setState(state)

    }

    func markSplashAnimationCompleted() {

        self.log(message: "Launch gate: splash animation completed")
        self.isSplashAnimationCompleted = true
        resolveLaunchIfPossible()

    }

    func start(onLaunchStateChanged: @escaping (LaunchScreenService.State) -> Void,
               onAuthError: @escaping (Error) -> Void,
               onNoNetwork: @escaping () -> Void,
               onHealthCheckResult: @escaping (_ requiresForceUpdate: Bool) -> Void) {

        guard !self.hasStarted else { return }
        self.hasStarted = true

        self.cancelBag = CancelBag()

        self.launchService
            .onLaunchStateChanged
            .receiveOnMain()
            .sink(receiveValue: onLaunchStateChanged)
            .store(in: &self.cancelBag)

        self.firebaseService
            .userPublisher
            .receiveOnMain()
            .sink { [weak self] user in

                self?.registerDeviceTokenTask?.cancel()
                self?.registerDeviceTokenTask = nil
                self?.deviceRegistrationId = nil

                guard let self else { return }
                guard !self.didResolveInitialAuthState else { return }

                self.didResolveInitialAuthState = true
                self.wasLoggedInAtStartup = (user != nil)

                if user == nil {

                    self.isAuthBootstrapCompleted = true
                    self.log(message: "Launch gate: initial user is logged out")
                    self.resolveLaunchIfPossible()
                    return

                }

                if self.authService.onInitialLoadCompleted.value {

                    self.isAuthBootstrapCompleted = true
                    self.log(message: "Launch gate: initial user already bootstrapped")
                    self.resolveLaunchIfPossible()

                }

            }
            .store(in: &self.cancelBag)

        self.authService
            .onInitialLoadCompleted
            .receiveOnMain()
            .sink { [weak self] didComplete in

                guard let self else { return }
                guard didComplete else { return }
                guard self.didResolveInitialAuthState else { return }
                guard self.wasLoggedInAtStartup else { return }

                self.isAuthBootstrapCompleted = true
                self.log(message: "Launch gate: logged-in bootstrap completed")
                self.resolveLaunchIfPossible()

            }
            .store(in: &self.cancelBag)

        self.environmentService
            .environmentPublisher
            .receiveOnMain()
            .sink { [weak self] environment in

                guard let self,
                      let environment else { return }

                self.runHealthCheck(for: environment) { requiresForceUpdate in
                    onHealthCheckResult(requiresForceUpdate)
                }

            }
            .store(in: &self.cancelBag)

        self.authService
            .currentUserPublisher
            .receiveOnMain()
            .sink { [weak self] user in

                self?.registerDeviceTokenTask?.cancel()
                self?.registerDeviceTokenTask = nil
                self?.deviceRegistrationId = nil

                guard user != nil else { return }
                guard let deviceToken = self?.appDelegateService.deviceToken else { return }
                self?.registerDeviceToken(deviceToken)

            }
            .store(in: &self.cancelBag)

        self.authService
            .onError
            .receiveOnMain()
            .sink { error in

                guard let error else { return }
                onAuthError(error)

            }
            .store(in: &self.cancelBag)

        self.appDelegateService
            .deviceTokenPublisher
            .receiveOnMain()
            .sink { [weak self] token in

                guard let token else { return }
                self?.registerDeviceToken(token)

            }
            .store(in: &self.cancelBag)

        self.connectivityService
            .onHasNetworkConnection
            .receiveOnMain()
            .sink { hasNetworkConnection in

                guard !hasNetworkConnection else { return }
                onNoNetwork()

            }
            .store(in: &self.cancelBag)

        self.viewLifecycleService
            .onWillEnterForeground
            .dropFirst(2)
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.scheduleForegroundUserRefresh()

            }
            .store(in: &self.cancelBag)

    }

    private func registerDeviceToken(_ token: String) {

        guard let user = self.authService.currentUser,
              let externalId = self.firebaseService.user?.uid,
              user.externalId == externalId else { return }

        self.registerDeviceTokenTask?.cancel()

        let apiService = self.apiService
        let authService = self.authService
        let firebaseService = self.firebaseService
        let userId = user.id
        let registrationId = UUID()
        self.deviceRegistrationId = registrationId

        self.registerDeviceTokenTask = Task { @MainActor [weak self] in

            defer {

                if self?.deviceRegistrationId == registrationId {

                    self?.registerDeviceTokenTask = nil
                    self?.deviceRegistrationId = nil

                }

            }

            do {

                guard !Task.isCancelled,
                      self?.deviceRegistrationId == registrationId,
                      authService.currentUser?.id == userId,
                      firebaseService.user?.uid == externalId else { return }

                try await apiService.registerDevice(
                    token: token,
                    userId: userId
                )

            }
            catch {

                guard !Task.isCancelled,
                      self?.deviceRegistrationId == registrationId,
                      authService.currentUser?.id == userId,
                      firebaseService.user?.uid == externalId else { return }

                self?.logError(
                    title: "Device Token Registration Error",
                    message: error.getMessageForError()
                )

            }

        }

    }

    private func resolveLaunchIfPossible() {

        guard !self.hasResolvedLaunchGate else { return }
        guard self.isAuthBootstrapCompleted else { return }

        if !self.hasStartedStoreBootstrap {

            self.hasStartedStoreBootstrap = true

            let storeSessionService = self.storeSessionService

            self.storeBootstrapTask = Task { @MainActor [weak self] in

                guard !Task.isCancelled else { return }

                await storeSessionService.bootstrap()
                guard !Task.isCancelled else { return }

                self?.isStoreBootstrapCompleted = true
                self?.resolveLaunchIfPossible()

            }

        }

        guard self.isStoreBootstrapCompleted else { return }
        guard self.isSplashAnimationCompleted else { return }

        self.hasResolvedLaunchGate = true
        self.log(message: "Launch gate: completed")

        self.launchService
            .setState(.completed)

    }

    private func runHealthCheck(for environment: AppEnvironment,
                                onHealthCheckResult: @escaping (_ requiresForceUpdate: Bool) -> Void) {

        self.healthCheckTask?.cancel()
        self.healthCheckTask = nil

        guard environment != .development else { return }

        let apiService = self.apiService

        self.healthCheckTask = Task { @MainActor [weak self] in

            guard !Task.isCancelled else { return }

            do {
                try await apiService.getHealth()
            }
            catch {

                guard !Task.isCancelled else { return }

                self?.logError(
                    title: "Health Check Error",
                    message: error.getMessageForError()
                )

                if let apiError = error as? APIError,
                   case let .serverError(statusCode, _) = apiError,
                   statusCode == 426 {
                    onHealthCheckResult(true)
                    return
                }

                onHealthCheckResult(false)

            }

        }

    }

    private func scheduleForegroundUserRefresh() {

        self.foregroundUserRefreshTask?.cancel()

        let authService = self.authService
        let storeSessionService = self.storeSessionService

        self.foregroundUserRefreshTask = Task { [weak self] in

            guard !Task.isCancelled else { return }

            do {
                try await authService.fetchUserInfoWithToken()
            }
            catch {

                guard !Task.isCancelled else { return }
                self?.logError(
                    title: "Foreground User Refresh Error",
                    message: error.getMessageForError()
                )

            }

            guard !Task.isCancelled else { return }
            await storeSessionService.bootstrap()

        }

    }

    private func cancelTasks() {

        self.foregroundUserRefreshTask?.cancel()
        self.registerDeviceTokenTask?.cancel()
        self.healthCheckTask?.cancel()
        self.storeBootstrapTask?.cancel()

    }

}
