# ViewModel Loading and Alerts

Use this contract with the [implementation guide](IMPLEMENTATION_BEST_PRACTICES.md#async-tasks-loading-and-cancellation) and [SwiftUI feature example](SWIFTUI_FEATURE_EXAMPLE.md). It adapts Grimoire's final loading pattern to LeafLaunch's actual customer/session contracts. The feature example is illustrative Swift, not a compiled implementation. Existing implementations include [StoreOverviewViewModel](../LeafLaunch/Screens/StoreDetails/Overview/StoreOverviewViewModel.swift) for parallel required requests and pagination, and [StoreAccountViewModel](../LeafLaunch/Screens/StoreDetails/Account/StoreAccountViewModel.swift) for authenticated-user/request ownership.

## Standard replacement flow

A standard new loader owns a named `Task<Void, Never>?`, cancels it before replacement, sets loading state before scheduling, snapshots dependencies and required context, and captures the ViewModel weakly. Keep UI and alert mutation on the main actor.

This excerpt belongs to the illustrative `UserDetailsViewModel` in the worked example. It uses the existing `AuthServiceProtocol.reloadUser()` and `LLUser`; do not introduce Grimoire's profile endpoint or user model into LeafLaunch.

```swift
func loadData(showHud: Bool) {

    guard let userId = self.userId else { return }

    self.loadUserTask?.cancel()
    self.isLoading = true

    let authService = self.authService
    let alertService = self.alertService

    self.loadUserTask = Task { @MainActor [weak self] in

        guard !Task.isCancelled else { return }

        let loadingIndicator = RuneAlert(.simpleLoadingIndicator)
        if showHud { alertService.showAlert(loadingIndicator) }

        defer {

            if showHud { alertService.dismissAlert(loadingIndicator) }

            if !Task.isCancelled {

                self?.isLoading = false
                self?.loadUserTask = nil

            }

        }

        do {

            guard authService.currentUser?.id == userId else { return }

            try await authService.reloadUser()
            guard !Task.isCancelled,
                  let user = authService.currentUser,
                  user.id == userId else { return }

            self?.user = user

        } catch {

            guard !Task.isCancelled,
                  authService.currentUser?.id == userId else { return }
            self?.presentProfileError()

        }

    }

}
```

Every invocation owns a unique alert identity. When B cancels A, A dismisses only A's loader. Its cancellation guard prevents it from publishing results, presenting an error, or clearing B's task/loading state. This cleanup guard is valid because every replacement cancels its predecessor and state changes occur on the main actor without an intervening suspension. Do not generalize it to identity changes, pagination, or service mutations without inspecting their ownership.

`showHud: false` suppresses the modal loader while preserving loading state and error handling. Do not clear successfully loaded values at refresh start; retain them if refresh fails. Snapshot query values and IDs alongside services. Check cancellation before sequential follow-up requests. Use `async let` for independent required requests and commit only after their combined success. A `try?` request must be deliberately optional with an explicit fallback.

## Existing ownership exceptions

- Preserve single-flight gates when a feature deliberately prevents overlap, such as load-more pagination, membership changes, or coupled catalog requests. Do not replace a mutation with a second mutation merely to mimic the example. A single-flight task can clear its own state unconditionally when no replacement can own that state.
- Preserve request-generation and authenticated-user checks in the account flow, query/context guards in catalog flows, and service-level session guards. Cancellation alone does not prove that a result still belongs to the current customer, store, or query. ViewModel checks cannot undo side effects already performed inside a service.
- An explicit cancellation/reset path must clear its own handle and loading state and invalidate its request/context token as appropriate. With cancel-before-replace, the replacement owns the new state. Do not leave a cancelled task installed while expecting its guarded cleanup to clear it.
- Cancel every owned task during deinitialization, using `isolated deinit` when required by the owning actor. Independent operations such as sign-out own independent tasks. Do not add unused subscriber bags or bind screen publishers in `init`.
- SwiftUI's `.task` does not cancel a separate stored task after calling a synchronous `loadData()`. Preserve explicit lifecycle cleanup for genuinely view-scoped sessions, capture, playback, and realtime work. Root/startup keeps its existing coordinator and splash sequencing.

These are LeafLaunch behavior and ownership constraints, not permission to weaken cancellation or presentation guards.

## Copy and presentation

[Constants.Message](../LeafLaunch/Helpers/Constants.swift) owns reusable alert copy. The formatter is `errorMessage(context:_:)`; its topic is unlabeled:

```swift
Constants.Message.errorMessage(context: .get, "profile")
Constants.Message.errorMessage(context: .create, "account")
Constants.Message.errorMessage(context: .update, "profile")
Constants.Message.errorMessage(context: .delete, "account")
```

Use the attempted operation's context. Add a focused message for wording such as sign-out that does not fit CRUD grammar. Keep raw transport diagnostics in the existing logging flow. Message constants do not own services, navigation, tasks, or actions.

The owning ViewModel presents through its injected AlertService and a focused helper:

```swift
private func presentProfileError() {

    self.alertService.showAlert(.init(
        .appAlert(
            .error(
                message: Constants.Message.errorMessage(context: .get, "profile"),
                action: {}
            )
        )
    ))

}
```

The helper can accept `message`, `context`, or a fixed feature topic when that matches its actual responsibility. Check cancellation and request/context ownership before calling it. Do not publish an `Error` solely to trigger `.errorHandler`; views do not own error-alert presentation. Keep inline error state when it drives persistent failure/retry UI.

Loading cleanup must call `dismissAlert(loadingIndicator)` for its exact instance. Broad dismissal such as `dismissLoadingIndicator()`, `dismiss()`, or `dismissAll()` can remove another operation's loader or a newly presented error. Use focused ViewModel methods for success and confirmation too. Present success after an awaited mutation succeeds and passes cancellation/ownership checks; a fetch does not need a success alert. Alert callbacks that reference the ViewModel capture `[weak self]`; an acknowledgement can remain `{}`.

App modal-card configuration belongs in focused `AppCardConfig` factories under [Components/Alerts](../LeafLaunch/Components/Alerts/), with separate content views where independently owned. Follow the existing dismissal/completion contract and active environment style. Toasts, when needed, use Rune's shared `ToastManager`, with presentation intent kept in the ViewModel.

## Lifecycle, state, and recovery

| Concern | Required behavior |
| --- | --- |
| First appearance | Install navigation/context, then call `handleFirstAppear()` to track once and bind applicable subscribers idempotently. Do not start the initial fetch there. |
| Initial/reappearance loading | `.task { [weak viewModel] in viewModel?.loadData(showHud: true) }` starts the loader. Stored-task cancellation belongs to its owner. |
| Loading | Set loading before scheduling and clear it only for the owning operation. Dismiss the exact task-owned loader in `defer`. |
| Initial success | Mark `hasCompletedInitialLoad` only after required work succeeds and cancellation/context checks pass. |
| Initial failure/cancellation | Do not mark a failed or cancelled request as a successful empty response. Leave a retry control reachable after failure. |
| Empty state | For a list, require initial success, no active loading, and no content. Keep actual root overlays on the full header/scroll container; contextual commerce states retain surrounding controls. |
| Refresh failure | Retain the last successful values and present the error. |
| One required entity | `user == nil` and `isLoading` may express initial/retry state; do not add list flags mechanically. |
| Identity/context change | Invalidate old work, reset its owned state, and retain existing account/query/session protections. |

Keep the screen as one `@StateObject` owner. Child views observe that instance or receive immutable values/actions. Live/mock/preview constructors, route setup, analytics, API fixtures, and explicit Xcode target membership must stay in parity when affected.

For review, inspect success, initial failure, refresh failure, rapid replacement, cancellation, context changes, and retry reachability. Do not write tests. Do not run tests or Xcode builds without an explicit request; report runtime behavior that remains unverified.
