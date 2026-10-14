import Foundation

enum NavigationSheet: Identifiable, Hashable, Sendable {

    case locations
    case ageVerification(locationId: String)

    var id: Self { self }

}
