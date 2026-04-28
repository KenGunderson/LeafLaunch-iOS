//
//  StatsigService.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Combine

final class StatsigService: StatsigServiceProtocol {

    internal let loggerName: String = "STATSIG_SERVICE"
    internal let loggerEmoji: String = "🚩"

    @Published private(set) var isReady: Bool = false
    var isReadyPublisher: AnyPublisher<Bool, Never> {
        return self.$isReady.eraseToAnyPublisher()
    }

    private var environmentProvider: EnvironmentProviding?
    private var authProvider: AuthProviding?
    private var cancelBag: CancelBag!
    private var initializeTask: Task<Void, Never>?
    private var latestUser: GPUser?
    private var didInitializeSDK: Bool = false
    private var shouldUseSDK: Bool = false

    init() {
        self.logInit()
    }

    deinit {
        self.initializeTask?.cancel()
        self.logDeinit()
    }

    // MARK: - Setup

    func setup(appDelegateService: AppDelegateServiceProtocol,
               environmentService: EnvironmentProviding,
               authProvider: AuthProviding) {

        self.log(message: "setup")

        self.environmentProvider = environmentService
        self.authProvider = authProvider
        self.latestUser = authProvider.currentUser
        self.cancelBag = CancelBag()

        appDelegateService
            .appWillTerminatePublisher
            .sink { [weak self] in
                self?.shutdown()
            }
            .store(in: &self.cancelBag)

        authProvider
            .currentUserPublisher
            .removeDuplicates()
            .receiveOnMain()
            .sink { [weak self] user in

                self?.latestUser = user

                guard self?.isReady == true else { return }

                Task {
                    await self?.identify(user: user)
                }

            }
            .store(in: &self.cancelBag)

        if let environmentService = environmentService as? EnvironmentServiceProtocol {

            environmentService
                .environmentPublisher
                .removeDuplicates(by: { lhs, rhs in
                    lhs?.displayName == rhs?.displayName
                })
                .receiveOnMain()
                .sink { [weak self] _ in
                    self?.scheduleInitialize()
                }
                .store(in: &self.cancelBag)

        }
        else {
            self.scheduleInitialize()
        }

    }

    // MARK: - Identity

    func identify(user: GPUser?) async {

        self.log(message: "identify: \(user?.id ?? "logged-out")")

        guard self.isReady else {
            self.log(message: "identify called before Statsig was ready — skipping")
            return
        }

        guard self.shouldUseSDK else {
            self.log(message: "identify skipped because Statsig SDK is disabled")
            return
        }

        let statsigUser = self.makeUserDebugDescription(from: user)
        self.log(message: "identify: prepared \(statsigUser)")

        // let statsigUser = makeStatsigUser(from: user)

        // Statsig.updateUserWithResult(statsigUser) { [weak self] result in
        //     switch result {
        //     case .success:
        //         self?.log(message: "identify: complete for \(user?.id ?? "logged-out")")
        //     case .failure(let error):
        //         self?.logError(title: "Identify Error", message: error.localizedDescription)
        //     }
        // }

    }

    // MARK: - Feature Flags

    func isEnabled(_ flag: FeatureFlag) -> Bool {

        self.log(message: "isEnabled(\(flag.displayName)) [\(flag.rawValue)]")

        guard self.isReady else {
            self.log(message: "isEnabled called before ready — returning default for \(flag.rawValue)")
            return flag.defaultValue
        }

        guard self.shouldUseSDK else {
            self.log(message: "isEnabled using default because Statsig SDK is disabled for \(flag.rawValue)")
            return flag.defaultValue
        }

        // return Statsig.checkGate(flag.rawValue)
        return flag.defaultValue

    }

    // MARK: - Dynamic Configs

    func value<Value>(_ parameter: DynamicConfigParameter<Value>) -> Value {

        self.log(message: "value(\(parameter.config.displayName).\(parameter.key))")

        guard self.isReady else {
            self.log(message: "Dynamic config called before ready — returning default for \(parameter.config.rawValue).\(parameter.key)")
            return parameter.defaultValue
        }

        guard self.shouldUseSDK else {
            self.log(message: "Dynamic config using default because Statsig SDK is disabled for \(parameter.config.rawValue).\(parameter.key)")
            return parameter.defaultValue
        }

        // let config = Statsig.getConfig(parameter.config.rawValue)
        // return config.getValue(
        //     forKey: parameter.key,
        //     defaultValue: parameter.defaultValue
        // )

        return parameter.defaultValue

    }

    // MARK: - Private

    private func scheduleInitialize() {

        self.initializeTask?.cancel()
        self.initializeTask = Task { [weak self] in
            await self?.initialize()
        }

    }

    private func initialize() async {

        self.log(message: "initialize: start")

        let environment = self.environmentProvider?.environment
        self.log(message: "initialize: environment=\(environment?.displayName ?? "nil")")

        await MainActor.run {
            if self.didInitializeSDK {
                self.shutdown()
            }

            self.isReady = false
            self.didInitializeSDK = false
            self.shouldUseSDK = false
        }

        guard !self.shouldSkipSDK(for: environment) else {
            await MainActor.run {
                self.isReady = true
                self.log(message: "initialize: skipped for local environment")
            }
            return
        }

        guard let sdkKey = Constants.Statsig.sdkKey(for: environment) else {
            await MainActor.run {
                self.isReady = true
                self.log(message: "initialize: skipped because Statsig sdk key is not configured")
            }
            return
        }

        let userDebugDescription = self.makeUserDebugDescription(from: self.latestUser)
        self.log(message: "initialize: sdkKey configured with \(sdkKey.count) characters, user=\(userDebugDescription)")

        // let tier: StatsigEnvironmentTier = (environment == .production) ? .Production : .Staging
        // let statsigEnvironment = StatsigEnvironment(tier: tier)
        // let options = StatsigOptions(
        //     environment: statsigEnvironment,
        //     overrideStableID: Constants.Device.deviceId
        // )
        // let user = makeStatsigUser(from: self.latestUser)

        // await withCheckedContinuation { continuation in
        //     Statsig.initialize(
        //         sdkKey: sdkKey,
        //         user: user,
        //         options: options
        //     ) { [weak self] error in
        //         if let error {
        //             self?.logError(title: "Initialize Error", message: error.localizedDescription)
        //         }
        //         continuation.resume()
        //     }
        // }

        await MainActor.run {
            self.didInitializeSDK = true
            self.shouldUseSDK = true
            self.isReady = true
            self.log(message: "initialize: ready")
        }

    }

    private func shutdown() {

        self.log(message: "shutdown")

        guard self.didInitializeSDK else {
            self.isReady = false
            self.shouldUseSDK = false
            return
        }

        // Statsig.shutdown()

        self.didInitializeSDK = false
        self.shouldUseSDK = false
        self.isReady = false

    }

    private func shouldSkipSDK(for environment: AppEnvironment?) -> Bool {

        switch environment {
        case .localhost:
            return true
        case .custom(let address):
            return address.contains("localhost") ||
                   address.contains("127.0.0.1") ||
                   address.contains("::1")
        case .development, .production:
            return false
        case .none:
            return true
        }

    }

    private func makeUserDebugDescription(from user: GPUser?) -> String {

        guard let user else { return "logged-out" }

        return [
            "id=\(user.id)",
            "email=\(user.email)",
            "externalId=\(user.externalId)"
        ]
        .joined(separator: ", ")

    }

    // MARK: - StatsigUser Builder

    // private func makeStatsigUser(from user: GPUser?) -> StatsigUser {
    //
    //     if let user {
    //
    //         return StatsigUser(
    //             userID: user.id,
    //             email: user.email,
    //             appVersion: Constants.App.version,
    //             custom: [
    //                 "first_name": user.firstName,
    //                 "last_name": user.lastName,
    //                 "external_id": user.externalId,
    //                 "app_build": Constants.App.buildNumber,
    //                 "bundle_identifier": Constants.App.bundleIdentifier
    //             ],
    //             customIDs: [
    //                 "stableID": Constants.Device.deviceId
    //             ]
        //         )
        //
        //     }
        //
    //     return StatsigUser(
    //         userID: nil,
    //         appVersion: Constants.App.version,
    //         custom: [
    //             "app_build": Constants.App.buildNumber,
    //             "bundle_identifier": Constants.App.bundleIdentifier
    //         ],
    //         customIDs: [
    //             "stableID": Constants.Device.deviceId
    //         ]
        //     )
        //
        // }

}
