import SwiftUI

struct EventDetailsScreen: GPView {

    @Environment(\.style) private var style
    @Environment(NavigationService.self) private var navigationService

    @StateObject private var viewModel: EventDetailsViewModel

    init(viewModel: EventDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {

        LLAppHeaderScrollView {
            navHeader()
        } scrollViewContent: {
            content()
        }
        .onFirstAppear { [weak viewModel] in

            viewModel?.setup(navigationService: self.navigationService)
            viewModel?.handleFirstAppear()

        }

    }

    @ViewBuilder
    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "Event Details"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ViewBuilder
    private func content() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.large)) {

            if let event = self.viewModel.event {

                eventImage(event)
                eventTitle(event)
                visitDetails()
                description(event)
                externalAction(event)

            }

        }
        .padding(.top, .small)
        .tabFlowContentSpacing()

    }

    @ViewBuilder
    private func eventImage(_ event: StoreEvent) -> some View {

        StoreMarketingImage(
            url: event.image?.url,
            placeholder: ImageResource(name: "StoreEventFallback", bundle: .main)
        )
        .aspectRatio(1.5, contentMode: .fit)
        .cornerRadius(.large)

    }

    @ViewBuilder
    private func eventTitle(_ event: StoreEvent) -> some View {

        Text(event.title)
            .appFont(with: .HEADER_3)
            .foregroundStyle(self.style.textColor(.title))
            .fixedSize(horizontal: false, vertical: true)

    }

    @ViewBuilder
    private func visitDetails() -> some View {

        CommerceSurface {

            VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                schedule()

                if let details = self.viewModel.locationDetails {

                    Divider().overlay(self.style.background(.border))
                    location(details)

                }

            }

        }

    }

    @ViewBuilder
    private func schedule() -> some View {

        if let schedule = self.viewModel.schedule {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                detailLabel(String(localized: "When"), systemImage: "calendar")

                if let startsAt = schedule.startsAt {

                    Text(String(localized: "Starts \(schedule.formattedDate(startsAt))"))
                        .appFont(with: .BODY_2)
                        .foregroundStyle(self.style.textColor(.title))

                } else {

                    Text(String(localized: "Date To Be Announced"))
                        .appFont(with: .BODY_2)
                        .foregroundStyle(self.style.textColor(.body))

                }

                if let endsAt = schedule.endsAt {

                    Text(String(localized: "Ends \(schedule.formattedDate(endsAt))"))
                        .appFont(with: .BODY_2)
                        .foregroundStyle(self.style.textColor(.body))

                }

                if schedule.startsAt != nil {

                    Text(schedule.timeZone.localizedName(for: .generic, locale: .current) ?? schedule.timeZone.identifier)
                        .appFont(with: .NOTE_1)
                        .foregroundStyle(self.style.textColor(.body))

                }

            }
            .fixedSize(horizontal: false, vertical: true)

        }

    }

    @ViewBuilder
    private func location(_ details: CustomerLocationDetails) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            detailLabel(String(localized: "Where"), systemImage: "mappin.and.ellipse")

            Text(details.location.name)
                .appFont(with: .TITLE_3)
                .foregroundStyle(self.style.textColor(.title))

            if !details.address.isEmpty {

                Text(details.address)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(self.style.textColor(.body))
                    .textSelection(.enabled)

            }

            if let directionsURL = self.viewModel.directionsURL {

                Link(destination: directionsURL) {
                    actionLabel(String(localized: "Get Directions"), systemImage: "arrow.up.right")
                }

            }

        }
        .fixedSize(horizontal: false, vertical: true)

    }

    @ViewBuilder
    private func detailLabel(_ title: String, systemImage: String) -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            ImageSource.systemImage(systemImage)
                .view(shouldResize: false)
            Text(title)

        }
        .appFont(with: .TITLE_2)
        .foregroundStyle(self.style.textColor(.body))

    }

    @ViewBuilder
    private func description(_ event: StoreEvent) -> some View {

        if let description = event.description?.trimmingCharacters(in: .whitespacesAndNewlines),
           !description.isEmpty {

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                CommerceSectionHeader(title: String(localized: "About This Event"))

                Text(description)
                    .appFont(with: .BODY_2)
                    .foregroundStyle(self.style.textColor(.body))
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)

            }

        }

    }

    @ViewBuilder
    private func externalAction(_ event: StoreEvent) -> some View {

        if let url = event.externalURL {

            CommerceSurface {

                Link(destination: url) {
                    actionLabel(String(localized: "Visit Event Website"), systemImage: "arrow.up.right")
                }

            }

        }

    }

    @ViewBuilder
    private func actionLabel(_ title: String, systemImage: String) -> some View {

        HStack(spacing: self.style.spacing(.small)) {

            Text(title)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: self.style.spacing(.small))
            ImageSource.systemImage(systemImage)
                .view(shouldResize: false)

        }
        .appFont(with: .TITLE_3)
        .foregroundStyle(self.style.foreground(.primary))
        .frame(minHeight: 44)
        .contentShape(Rectangle())

    }

}

#Preview {

    if let event = MockCustomerModels.events.first {

        EventDetailsScreen(
            viewModel: mockResolve(EventDetailsViewModel.self)
                .setup(locationId: MockCustomerModels.primaryLocationId, event: event)
        )
        .withMockPreviews()

    }

}
