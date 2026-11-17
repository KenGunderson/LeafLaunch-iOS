import SwiftUI

struct MainScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @State private var alertServiceWrapper: RNObservableAlertServiceWrapper
    @StateObject private var viewModel: MainViewModel

    init(viewModel: MainViewModel) {

        self._alertServiceWrapper = State(wrappedValue: RNObservableAlertServiceWrapper(alertService: viewModel.readOnlyAlertService))
        self._viewModel = StateObject(wrappedValue: viewModel)

    }

    var body: some View {

        customerFlow()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .runeBackground(.primary)
            .environment(self.viewModel.tabBarNavigationService)
            .runeWithWindowToastOverlay()
            .runeWithWindowAlertService(self.alertServiceWrapper)
            .runeWithWindowDynamicIslandService()
            .withFullScreenCover(Bindable(self.navigationService).fullScreenCover)
            .withSheet(Bindable(self.navigationService).sheet) { [weak viewModel] in
                viewModel?.handleSheetDismissal()
            }
            .withDevSettingsOverlay(isEnabled: self.viewModel.isDevSettingsEnabled) {
                self.navigationService.modal(fullScreenCover: .devSettings)
            }
            .onFirstAppear { [weak viewModel] in

                viewModel?.setup(navigationService: self.navigationService)
                viewModel?.handleFirstAppear()

            }

    }

    @ContentBuilder
    private func customerFlow() -> some View {

        switch self.viewModel.storeState {
        case .loading,
                .locations,
                .ageVerification,
                .store:

            StoreContainerScreen(viewModel: self.viewModel.storeContainerViewModel)
                .id(self.viewModel.storeContainerViewModel.locationId)

        case .configurationRequired:

            statusBox(title: "Store Configuration Required") {
                Text("This app is waiting for its store configuration.")
            }

        case .unavailable:

            unavailableStatus()

        case .updateRequired:

            updateRequiredStatus()

        case .failed:

            failureStatus()
        }

    }

    @ContentBuilder
    private func statusBox<Content: View>(title: LocalizedStringKey,
                                          @ContentBuilder content: () -> Content) -> some View {

        CommerceSurface {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.listRow)
            ) {

                Text(title).runeFont(with: .TITLE_3)
                content()

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .runePadding(LLSpacing.pageInset)

    }

    @ContentBuilder
    private func unavailableStatus() -> some View {

        statusBox(title: "Store Unavailable") {

            Text("There are no stores available to browse right now.")
            LeafLaunchButton(title: "Try Again") { self.viewModel.retryStoreLoading() }

        }

    }

    @ContentBuilder
    private func updateRequiredStatus() -> some View {

        statusBox(title: "App Update Required") {

            Text("Update this app to continue browsing.")

            if let updateURL = self.viewModel.updateURL {

                Link(
                    "Update App",
                    destination: updateURL
                )

            }

            LeafLaunchButton(title: "Check Again") { self.viewModel.retryStoreLoading() }

        }

    }

    @ContentBuilder
    private func failureStatus() -> some View {

        statusBox(title: "Unable To Load Stores") {

            Text(self.viewModel.storeErrorMessage ?? "Check your connection and try again.")
            LeafLaunchButton(title: "Try Again") { self.viewModel.retryStoreLoading() }
            Text("Choose Another Location")
                .runeForeground(.primary)
                .runeAsButton { self.viewModel.chooseAnotherLocation() }

        }

    }

}

#Preview {

    MainScreen(viewModel: mockResolve(MainViewModel.self))
        .withMockPreviews()

}
