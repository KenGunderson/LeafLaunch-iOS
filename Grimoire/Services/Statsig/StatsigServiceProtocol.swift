//
//  StatsigServiceProtocol.swift
//  Grimoire
//
//  Created by Sako Hovaguimian on 4/27/26.
//

import Combine

// MARK: - FeatureFlagProviding

protocol FeatureFlagProviding: AnyObject {

    func isEnabled(_ flag: FeatureFlag) -> Bool

}

// MARK: - StatsigDynamicConfig

enum StatsigDynamicConfig: String, CaseIterable {

    // Add cases here. The raw value must match the dynamic config name in the Statsig console.

    case exampleConfig = "example_config"

    var displayName: String {
        switch self {
        case .exampleConfig: return "Example Config"
        }
    }

}

// MARK: - DynamicConfigParameter

struct DynamicConfigParameter<Value> {

    let config: StatsigDynamicConfig
    let key: String
    let defaultValue: Value

    init(
        config: StatsigDynamicConfig,
        key: String,
        defaultValue: Value
    ) {
        self.config = config
        self.key = key
        self.defaultValue = defaultValue
    }

}

// MARK: - DynamicConfigParameters

enum DynamicConfigParameters {

    enum ExampleConfig {

        static let title = DynamicConfigParameter(
            config: .exampleConfig,
            key: "title",
            defaultValue: "Default Title"
        )

        static let isEnabled = DynamicConfigParameter(
            config: .exampleConfig,
            key: "is_enabled",
            defaultValue: false
        )

        static let maxCount = DynamicConfigParameter(
            config: .exampleConfig,
            key: "max_count",
            defaultValue: 10
        )

    }

}

// MARK: - DynamicConfigProviding

protocol DynamicConfigProviding: AnyObject {

    func value<Value>(_ parameter: DynamicConfigParameter<Value>) -> Value

}

// MARK: - StatsigServiceProtocol

protocol StatsigServiceProtocol: FeatureFlagProviding, DynamicConfigProviding, Loggable {

    var isReady: Bool { get }
    var isReadyPublisher: AnyPublisher<Bool, Never> { get }

    func setup(
        appDelegateService: AppDelegateServiceProtocol,
        environmentService: EnvironmentProviding,
        authProvider: AuthProviding
    )

    func identify(user: GPUser?) async

}


//let title = statsigService.value(DynamicConfigParameters.ExampleConfig.title)
//let isEnabled = statsigService.value(DynamicConfigParameters.ExampleConfig.isEnabled)
//let maxCount = statsigService.value(DynamicConfigParameters.ExampleConfig.maxCount)
//
//// Optional Shorthand
//
//typealias Configs = DynamicConfigParameters
//let title = statsigService.value(Configs.ExampleConfig.title)
