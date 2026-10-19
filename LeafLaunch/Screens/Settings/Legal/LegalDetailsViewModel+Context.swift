import Foundation

extension LegalDetailsViewModel {

    enum Context {

        case termsAndConditions
        case privacyPolicy
        case subscriptionTerms

        var displayName: String {

            switch self {
            case .termsAndConditions: return "Terms And Conditions"
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

}
