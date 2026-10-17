import SwiftUI

struct LocationsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: LocationsViewModel

    init(viewModel: LocationsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        LLAppHeaderScrollView {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .interactiveDismissDisabled()
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }
        .task { [weak viewModel] in
            viewModel?.loadData(showHud: true)
        }

    }

    @ViewBuilder
    private func navHeader() -> some View {

        StoreNavHeader(
            configuration: self.viewModel.configuration,
            subtitle: String(localized: "Choose a location")
        )
        .safeAreaPadding(.top, self.style.spacing(.medium))

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            if self.viewModel.locations.isEmpty {

                CommerceEmptyState(
                    systemImage: "mappin.and.ellipse",
                    title: String(localized: "No locations available"),
                    message: String(localized: "There are no available locations.")
                )

            } else {

                introduction()

                locations()
                retryAction()

            }

        }
        .foregroundStyle(self.style.textColor(.body))
        .padding(.bottom, self.style.spacing(.large))

    }

    @ViewBuilder
    private func locations() -> some View {

        LazyVStack(spacing: self.style.spacing(.medium)) {

            ForEach(self.viewModel.locations, id: \.id) { location in
                locationRow(location)
            }

        }

    }

    @ViewBuilder
    private func locationRow(_ location: BootstrapLocation) -> some View {

        LocationSelectionCard(
            location: location,
            details: self.viewModel.locationDetails[location.id],
            isLoading: self.viewModel.isLoading
        ) { [weak viewModel] in
            viewModel?.selectLocation(id: location.id)
        }

    }

    @ViewBuilder
    private func introduction() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(String(localized: "Find your local store."))
                .appFont(with: .HEADER_3)
                .foregroundStyle(self.style.textColor(.title))

            Text(String(localized: "Choose a location to explore its shop and latest updates."))
                .appFont(with: .BODY_2)
                .foregroundStyle(self.style.textColor(.body))
                .fixedSize(horizontal: false, vertical: true)

        }

    }

    @ViewBuilder
    private func retryAction() -> some View {

        if !self.viewModel.failedLocationIds.isEmpty {

            LeafLaunchButton(
                title: String(localized: "Retry location details"),
                icon: .systemImage("arrow.clockwise")
            ) { [weak viewModel] in
                viewModel?.loadData(showHud: true)
            }
            .disabled(self.viewModel.isLoading)

        }

    }

}

#Preview {

    LocationsScreen(viewModel: mockResolve(LocationsViewModel.self))
        .withMockPreviews()

}
