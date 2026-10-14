import SwiftUI

struct StoreOverviewScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: StoreOverviewViewModel

    init(viewModel: StoreOverviewViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    private func weekday(_ value: Int) -> String {

        let symbols = DateFormatter().weekdaySymbols ?? []
        return symbols.indices.contains(value) ? symbols[value] : String(value)

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

        .task { [weak viewModel] in
            viewModel?.loadData(showHud: true)
        }

    }

    private func navHeader() -> some View {
        NavHeader(title: self.viewModel.locationDetails?.location.name ?? String(localized: "Store"))
    }

    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

            LeafLaunchButton(title: String(localized: "Change Location")) {
                self.viewModel.changeLocation()
            }

            promotions()
            events()
            storeInfo()

            LeafLaunchButton(title: String(localized: "Refresh Store")) {
                self.viewModel.loadData(showHud: true)
            }
            .disabled(self.viewModel.isLoading)

        }
        .foregroundStyle(.text(.body))
        .tabFlowContentSpacing()

    }

    private func promotions() -> some View {

        GroupBox(String(localized: "Promos")) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                if self.viewModel.hasCompletedInitialLoad && self.viewModel.promotions.isEmpty {
                    Text(String(localized: "No current promotions."))
                }

                ForEach(self.viewModel.promotions, id: \.id) { promotion in

                    VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                        Text(promotion.title).appFont(with: .TITLE_4)
                        Text(promotion.description ?? "").appFont(with: .BODY_2)
                        Divider()

                    }

                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    private func events() -> some View {

        GroupBox(String(localized: "Upcoming Events")) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                if self.viewModel.hasCompletedInitialLoad && self.viewModel.events.isEmpty {
                    Text(String(localized: "No upcoming events."))
                }

                ForEach(self.viewModel.events, id: \.id) { event in

                    VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                        Text(event.title).appFont(with: .TITLE_4)
                        Text(event.description ?? "").appFont(with: .BODY_2)

                        if let startsAt = event.startsAt {
                            Text(startsAt.formatted(date: .abbreviated, time: .shortened))
                        }

                        if let externalURL = event.externalURL {
                            Link(String(localized: "Event Details"), destination: externalURL)
                        }

                        Divider()

                    }

                }

                if self.viewModel.hasMoreEvents {

                    LeafLaunchButton(title: String(localized: "Load More Events")) {
                        self.viewModel.loadMoreEvents()
                    }
                    .disabled(self.viewModel.isLoadingEvents)

                }

            }
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

    private func storeInfo() -> some View {

        GroupBox(String(localized: "Store Info")) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                if let store = self.viewModel.store {

                    Text(store.name).appFont(with: .TITLE_4)

                    if let legalName = store.legalName, legalName != store.name {
                        Text(legalName)
                    }

                    if let supportEmail = store.supportEmail {
                        Text(supportEmail)
                    }

                    if let supportPhone = store.supportPhone {
                        Text(supportPhone)
                    }

                    if let websiteURL = store.websiteURL {
                        Link(String(localized: "Business Website"), destination: websiteURL)
                    }

                }

                if let details = self.viewModel.locationDetails {

                    Text(details.location.name)
                    Text(details.mapsAddress)
                    Text(details.openNow ? String(localized: "Open now") : String(localized: "Closed now"))
                    Text(details.location.timezone ?? "")

                    ForEach(details.location.hours ?? [], id: \.id) { hours in

                        HStack {

                            Text(weekday(hours.weekday))
                            Spacer()
                            Text(hours.closed ? String(localized: "Closed") : "\(hours.opensAt ?? "—") – \(hours.closesAt ?? "—")")

                        }

                    }

                }

            }
            .appFont(with: .BODY_2)
            .frame(maxWidth: .infinity, alignment: .leading)

        }

    }

}

#Preview {

    StoreOverviewScreen(
        viewModel: mockResolve(StoreOverviewViewModel.self)
            .setup(locationId: MockCustomerModels.primaryLocationId)
    )
    .withMockServices()

}
