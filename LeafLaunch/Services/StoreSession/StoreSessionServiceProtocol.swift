import Combine
import Foundation

@MainActor
protocol StoreSessionServiceProtocol: AnyObject, Sendable {

    var state: StoreSessionState { get }
    var statePublisher: AnyPublisher<StoreSessionState, Never> { get }
    var configuration: CustomerBootstrap? { get }
    var locationDetails: CustomerLocationDetails? { get }
    var locations: [BootstrapLocation] { get }
    var error: Error? { get }
    var minimumAge: Int { get }
    var ageVerificationState: String { get }

    func bootstrap() async
    func selectLocation(id: String)
    func showLocations()
    func approveAgeVerification()

}
