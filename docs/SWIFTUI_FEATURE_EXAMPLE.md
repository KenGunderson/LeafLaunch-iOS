# SwiftUI Feature Example

This documentation-only example shows a user-profile screen using the [implementation rules](IMPLEMENTATION_BEST_PRACTICES.md). The three types below are illustrative new types, not additions to the app. They reuse LeafLaunch's existing `GPUser`, `APIServiceProtocol.getUser(id:)`, profile analytics event, navigation service, and UI components.

The screen owns presentation and lifecycle wiring. Its ViewModel owns fetching and navigation actions. The card receives a user, loading state, and an action, so it does not need a ViewModel or service dependency.

The snippets follow the user's corrected spacing: expanded bodies and nested groups have blank lines inside their braces, while short helpers and closures stay compact. Preserve this layout when using the example; it is LeafLaunch's default style, not an exception for older files.

If implemented, keep the files together under `LeafLaunch/Screens/UserDetails/`, with the card in its `Views/` subdirectory. No new model or service protocol is necessary. The integration excerpts later in this document show the wiring the example would require; none has been applied to production code.

## ViewModel: UserDetailsViewModel.swift

The route installs `userId` before the screen appears. The first-appearance entry point tracks the screen and starts the request. Repeated refresh taps cannot overlap requests, so the example needs neither request-generation identifiers nor replacement-task bookkeeping.

```swift
import SwiftUI

@MainActor
final class UserDetailsViewModel: ViewModel {

    let loggerName: String = "USER_DETAILS_VIEW_MODEL"
    let loggerEmoji: String = "👤"

    private let apiService: APIServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let alertService: AlertServiceProtocol

    private weak var navigationService: NavigationService?
    private var userId: String?
    private var loadUserTask: Task<Void, Never>?

    @Published private(set) var user: GPUser?
    @Published private(set) var isLoading: Bool = false
    @Published var error: Error?

    init(apiService: APIServiceProtocol,
         analyticsService: AnalyticsServiceProtocol,
         alertService: AlertServiceProtocol) {
        self.apiService = apiService
        self.analyticsService = analyticsService
        self.alertService = alertService

        logInit()

    }

    isolated deinit {

        self.loadUserTask?.cancel()
        logDeinit()

    }

    @discardableResult
    func setup(userId: String) -> Self {

        self.userId = userId
        return self

    }

    func setup(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    func handleFirstAppear() {

        track()
        loadUser()

    }

    func loadUser() {

        guard self.loadUserTask == nil,
              let userId = self.userId else { return }

        let apiService = self.apiService
        let alertService = self.alertService

        self.isLoading = true
        self.error = nil
        alertService.showAlert(.init(.simpleLoadingIndicator))

        self.loadUserTask = Task { [weak self] in

            defer {

                self?.isLoading = false
                self?.loadUserTask = nil

                alertService.dismissLoadingIndicator()

            }

            do {

                let user = try await apiService.getUser(id: userId)
                guard !Task.isCancelled else { return }

                self?.user = user

            } catch {

                guard !Task.isCancelled else { return }
                self?.error = error

            }

        }

    }

    func dismiss() {
        self.navigationService?.pop()
    }

}

extension UserDetailsViewModel {

    func track() {

        guard let userId = self.userId else { return }
        self.analyticsService.track(screen: .profile(.profile(userId: userId)))

    }

}
```

There are no publisher subscriptions, so there is no `CancelBag` or empty `bindSubscribers()` method. The task captures dependencies and the user ID before suspension, holds the ViewModel weakly, and checks cancellation before publishing a result or error. Cleanup runs through `defer`, including when the ViewModel cancels the request during deinitialization. Existing content stays visible if a refresh fails.

## Screen: UserDetailsScreen.swift

The environment properties come first, followed by the state owner, initialization, and view logic. Navigation is injected before first-appearance work. Loading starts only through `handleFirstAppear()`; an additional `.task` hook would duplicate the request.

```swift
import SwiftUI

struct UserDetailsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: UserDetailsViewModel

    init(viewModel: UserDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .medium) {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .errorHandler(
            error: self.$viewModel.error,
            alertStyle: .simpleError(
                title: String(localized: "Unable to Load Profile"),
                message: Constants.Message.errorMessage("profile"),
                action: { [weak viewModel] in
                    viewModel?.error = nil
                }
            )
        )
        .onFirstAppear { [weak viewModel] in
            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()
        }

    }

    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "User Profile"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in
                viewModel?.dismiss()
            }
        )

    }

    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            if let user = self.viewModel.user {

                UserDetailsCard(
                    user: user,
                    isRefreshing: self.viewModel.isLoading,
                    onRefresh: {
                        self.viewModel.loadUser()
                    }
                )

            } else if !self.viewModel.isLoading {

                LeafLaunchButton(title: String(localized: "Load Profile")) {
                    self.viewModel.loadUser()
                }

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .medium)
    }

}

#Preview {

    UserDetailsScreen(
        viewModel: mockResolve(UserDetailsViewModel.self)
            .setup(userId: MockModels.MockUser.user1.id)
    )
    .withMockServices()

}
```

`content()` returns one `VStack`, so it does not need `@ViewBuilder`; the stack's builder handles its conditional children. A failed initial request offers another load without pretending that a successful empty response occurred. This endpoint returns one required user, so list-specific empty-state flags and overlays would add unnecessary state. The preview assumes the mock registrations shown below, and uses the existing fixture and environment wrapper.

## View component: Views/UserDetailsCard.swift

This is a feature-owned composition of the existing card and button components. It does not add a parallel card/button design system or resolve dependencies. Its `onRefresh` closure expresses the interaction without coupling the component to this particular ViewModel.

```swift
import SwiftUI

struct UserDetailsCard: View {

    @Environment(\.style) private var style

    private let user: GPUser
    private let isRefreshing: Bool
    private let onRefresh: () -> Void

    init(user: GPUser,
         isRefreshing: Bool,
         onRefresh: @escaping () -> Void) {

        self.user = user
        self.isRefreshing = isRefreshing
        self.onRefresh = onRefresh

    }

    var body: some View {

        LeafLaunchCardView(title: self.user.fullName) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                Text(self.user.email)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(.text(.body))
                    .textSelection(.enabled)

                LeafLaunchButton(
                    title: String(localized: "Refresh"),
                    icon: .systemImage("arrow.clockwise"),
                    action: self.onRefresh
                )
                .disabled(self.isRefreshing)

            }

        }

    }

}

#Preview {

    AppBaseView {

        UserDetailsCard(
            user: MockModels.MockUser.user1,
            isRefreshing: false,
            onRefresh: {}
        )

    }
    .withMockServices()

}
```

The component uses environment spacing, semantic text styling, and `ImageSource` through `LeafLaunchButton`. It receives immutable values rather than creating another `@StateObject`. An extracted form that edits the same screen state would instead use `@ObservedObject` with the screen's existing ViewModel instance.

## Integration excerpts

These excerpts illustrate the existing FactoryKit and navigation patterns. They are documentation, not changes to the files linked below. Applying the three Swift types to the app would also require all applicable wiring here and explicit target membership in `project.pbxproj`.

In [live ViewModel factories](../LeafLaunch/DI/Live/ViewModelAssembly.swift), add the factory using only the three dependencies the feature needs:

```swift
extension Container {

    @MainActor
    var userDetailsViewModel: Factory<UserDetailsViewModel> {
        self { @MainActor in
            UserDetailsViewModel(
                apiService: self.apiService(),
                analyticsService: self.analyticsService(),
                alertService: self.alertService()
            )
        }
    }

}
```

Inside the existing [mock ViewModel assembly](../LeafLaunch/DI/Mock/MockViewModelAssembly.swift) `assemble(container:)`, register the same constructor against mock services:

```swift
container.userDetailsViewModel.register { @MainActor in

    UserDetailsViewModel(
        apiService: container.apiService(),
        analyticsService: container.analyticsService(),
        alertService: container.alertService()
    )

}
```

Inside the existing [mock resolver](../LeafLaunch/DI/Mock/MockAssembler.swift) `resolve<T>(_:)`, before its fallback, follow the current resolver convention:

```swift
if type == UserDetailsViewModel.self {
    return self.container.userDetailsViewModel() as! T
}
```

For a dedicated destination, a new case in the existing [Route enum](../LeafLaunch/Services/Navigation/Models/Routes.swift) would carry its required context:

```swift
case userDetails(userId: String)
```

Its corresponding branch in the outer route switch of the existing [navigation destination builder](../LeafLaunch/Services/Navigation/NavigationService.swift) would configure the resolved ViewModel before constructing the screen:

```swift
case .userDetails(let userId):

    let viewModel = Container.shared.userDetailsViewModel()
        .setup(userId: userId)

    UserDetailsScreen(viewModel: viewModel)
        .navigationBarBackButtonHidden()
```

The existing `.profile(.profile(userId:))` event already maps to `screen_view`, and existing live/mock API implementations already supply `getUser(id:)`. This example requires no new analytics case, endpoint, service registration, or domain model. These references were checked against the current source, but the illustrative Swift has not been compiled or run; no Xcode build or tests were requested.
