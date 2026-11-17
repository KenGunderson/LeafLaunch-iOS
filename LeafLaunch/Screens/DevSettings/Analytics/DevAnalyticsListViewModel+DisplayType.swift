import Foundation

extension DevAnalyticsListViewModel {

    enum DisplayType: String, CaseIterable {

        case logs
        case analytics
        case api

        var title: String {

            switch self {
            case .logs: "Logs"
            case .analytics: "Analytics"
            case .api: "API"
            }

        }

    }

}
