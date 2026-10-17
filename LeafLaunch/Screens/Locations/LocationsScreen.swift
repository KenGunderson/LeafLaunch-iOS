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

    }

    @ViewBuilder
    private func navHeader() -> some View {
        NavHeader(title: self.viewModel.businessName, subtitle: String(localized: "Choose a location"))
    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            if self.viewModel.locations.isEmpty {

                CommerceEmptyState(
                    systemImage: "mappin.and.ellipse",
                    title: String(localized: "No locations available"),
                    message: String(localized: "There are no available locations.")
                )

            } else {

                introduction()

                locations()

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

        LocationSelectionCard(location: location) { [weak viewModel] in
            viewModel?.selectLocation(id: location.id)
        }

    }

    @ViewBuilder
    private func introduction() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            ImageSource.systemImage("storefront")
                .view(shouldResize: false)
                .appFont(with: .HEADER_3)
                .foregroundStyle(self.style.foreground(.primary))
                .padding(self.style.spacing(.medium))
                .background(self.style.background(.tertiary), in: Circle())

            Text(String(localized: "Find your local store."))
                .appFont(with: .HEADER_3)
                .foregroundStyle(self.style.textColor(.title))

            Text(String(localized: "Choose a location to explore its shop and latest updates."))
                .appFont(with: .BODY_2)
                .foregroundStyle(self.style.textColor(.body))
                .fixedSize(horizontal: false, vertical: true)

        }
        .padding(.vertical, self.style.spacing(.small))

    }

}

#Preview {

    LocationsScreen(viewModel: mockResolve(LocationsViewModel.self))
        .withMockPreviews()

}
