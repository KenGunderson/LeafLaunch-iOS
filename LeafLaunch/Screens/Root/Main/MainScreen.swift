import SwiftUI

struct MainScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: MainViewModel

    init(viewModel: MainViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        customerFlow()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(self.style.background(.primary))
            .environment(self.viewModel.tabBarNavigationService)
            .withWindowToastOverlay()
            .withWindowAlertService(.init(alertService: self.viewModel.readOnlyAlertService))
            .withWindowDynamicIslandService()
            .withFullScreenCover(Bindable(self.navigationService).fullScreenCover)
            .withSheet(Bindable(self.navigationService).sheet)
            .withDevSettingsOverlay(isEnabled: self.viewModel.isDevSettingsEnabled) {
                self.navigationService.modal(fullScreenCover: .devSettings)
            }
            .onFirstAppear { [weak viewModel] in

                viewModel?.setup(navigationService: self.navigationService)
                viewModel?.handleFirstAppear()

            }

    }

    @ViewBuilder
    private func customerFlow() -> some View {

        switch self.viewModel.storeState {
        case .loading, .locations, .ageVerification, .store:

            StoreDetailsScreen(viewModel: self.viewModel.storeDetailsViewModel)
                .id(self.viewModel.storeDetailsViewModel.locationId)

        case .configurationRequired:

            statusBox(title: "Store configuration required") {
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

    @ViewBuilder
    private func statusBox<Content: View>(title: LocalizedStringKey,
                                          @ViewBuilder content: () -> Content) -> some View {

        CommerceSurface {

            VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                Text(title).appFont(with: .TITLE_3)
                content()

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }
        .padding(self.style.spacing(.medium))

    }

    @ViewBuilder
    private func unavailableStatus() -> some View {

        statusBox(title: "Store unavailable") {

            Text("There are no stores available to browse right now.")
            LeafLaunchButton(title: "Try again") { self.viewModel.retryStoreLoading() }

        }

    }

    @ViewBuilder
    private func updateRequiredStatus() -> some View {

        statusBox(title: "App update required") {

            Text("Update this app to continue browsing.")

            if let updateURL = self.viewModel.updateURL {
                Link("Update app", destination: updateURL)
            }

            LeafLaunchButton(title: "Check again") { self.viewModel.retryStoreLoading() }

        }

    }

    @ViewBuilder
    private func failureStatus() -> some View {

        statusBox(title: "Unable to load stores") {

            Text(self.viewModel.storeErrorMessage ?? "Check your connection and try again.")
            LeafLaunchButton(title: "Try again") { self.viewModel.retryStoreLoading() }
            Text("Choose another location")
                .foregroundStyle(.foreground(.primary))
                .asButton { self.viewModel.chooseAnotherLocation() }

        }

    }

}

#Preview {

    MainScreen(viewModel: mockResolve(MainViewModel.self))
        .withMockPreviews()

}
