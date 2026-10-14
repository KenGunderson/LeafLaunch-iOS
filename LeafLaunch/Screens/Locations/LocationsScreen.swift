import SwiftUI

struct LocationsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: LocationsViewModel

    init(viewModel: LocationsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        AppHeaderScrollView(horizontalPadding: .medium) {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }

    }

    private func navHeader() -> some View {
        NavHeader(title: self.viewModel.businessName, subtitle: String(localized: "Choose a location"))
    }

    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            if self.viewModel.locations.isEmpty {
                Text(String(localized: "There are no available locations."))
            }

            ForEach(self.viewModel.locations, id: \.id) { location in

                GroupBox {

                    VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                        Text(location.name).appFont(with: .TITLE_4)
                        Text(location.timezone ?? "").appFont(with: .BODY_2)

                        LeafLaunchButton(title: String(localized: "Open Location")) {
                            self.viewModel.selectLocation(id: location.id)
                        }

                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                }

            }

        }
        .foregroundStyle(.text(.body))

    }

}

#Preview {

    LocationsScreen(viewModel: mockResolve(LocationsViewModel.self))
        .withMockServices()

}
