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

    @ContentBuilder
    private func navHeader() -> some View {

        NavHeader(
            title: String(localized: "Event Details"),
            leadingNavButtons: [.back],
            leadingNavButtonsAction: { [weak viewModel] _ in viewModel?.dismiss() }
        )

    }

    @ContentBuilder
    private func content() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.content)
        ) {

            if let event = self.viewModel.event {

                eventImage(event)
                eventTitle(event)
                visitDetails()
                description(event)
                externalAction(event)

            }

        }
        .runePadding(.top, LLSpacing.groupedContent)
        .tabFlowContentSpacing()

    }

    @ContentBuilder
    private func eventImage(_ event: StoreEvent) -> some View {

        StoreMarketingImage(
            url: event.image?.url,
            placeholder: ImageResource(
                name: "StoreEventFallback",
                bundle: .main
            )
        )
        .aspectRatio(
            1.5,
            contentMode: .fit
        )
        .runeCornerRadius(.large)

    }

    @ContentBuilder
    private func eventTitle(_ event: StoreEvent) -> some View {

        Text(event.title)
            .runeFont(with: .HEADER_3)
            .runeTextColor(.title)
            .fixedSize(
                horizontal: false,
                vertical: true
            )

    }

    @ContentBuilder
    private func visitDetails() -> some View {

        CommerceSurface {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.listRow)
            ) {

                schedule()

                if let details = self.viewModel.locationDetails {

                    LLDivider()
                    location(details)

                }

            }

        }

    }

    @ContentBuilder
    private func schedule() -> some View {

        if let schedule = self.viewModel.schedule {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                detailLabel(
                    String(localized: "When"),
                    systemImage: "calendar"
                )

                if let startsAt = schedule.startsAt {

                    Text(String(localized: "Starts \(schedule.formattedDate(startsAt))"))
                        .runeFont(with: .BODY_2)
                        .runeTextColor(.title)

                } else {

                    Text(String(localized: "Date To Be Announced"))
                        .runeFont(with: .BODY_2)
                        .runeTextColor(.body)

                }

                if let endsAt = schedule.endsAt {

                    Text(String(localized: "Ends \(schedule.formattedDate(endsAt))"))
                        .runeFont(with: .BODY_2)
                        .runeTextColor(.body)

                }

                if schedule.startsAt != nil {

                    Text(schedule.timeZone.localizedName(
                        for: .generic,
                        locale: .current
                    ) ?? schedule.timeZone.identifier)
                        .runeFont(with: .NOTE_1)
                        .runeTextColor(.body)

                }

            }
            .fixedSize(
                horizontal: false,
                vertical: true
            )

        }

    }

    @ContentBuilder
    private func location(_ details: CustomerLocationDetails) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            detailLabel(
                String(localized: "Where"),
                systemImage: "mappin.and.ellipse"
            )

            Text(details.location.name)
                .runeFont(with: .TITLE_3)
                .runeTextColor(.title)

            if !details.address.isEmpty {

                Text(details.address)
                    .runeFont(with: .BODY_2)
                    .runeTextColor(.body)
                    .textSelection(.enabled)

            }

            if let directionsURL = self.viewModel.directionsURL {

                Link(destination: directionsURL) {

                    actionLabel(
                        String(localized: "Get Directions"),
                        systemImage: "arrow.up.right"
                    )

                }

            }

        }
        .fixedSize(
            horizontal: false,
            vertical: true
        )

    }

    @ContentBuilder
    private func detailLabel(_ title: String, systemImage: String) -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            RNImageSource.systemImage(systemImage)
                .view(shouldResize: false)
            Text(title)

        }
        .runeFont(with: LeafLaunchThemeTokens.headingFont)
        .runeTextColor(.body)

    }

    @ContentBuilder
    private func description(_ event: StoreEvent) -> some View {

        if let description = event.description?.trimmingCharacters(in: .whitespacesAndNewlines),
           !description.isEmpty {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                CommerceSectionHeader(title: String(localized: "About This Event"))

                Text(description)
                    .runeFont(with: .BODY_2)
                    .runeTextColor(.body)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .textSelection(.enabled)

            }

        }

    }

    @ContentBuilder
    private func externalAction(_ event: StoreEvent) -> some View {

        if let url = event.externalURL {

            CommerceSurface {

                Link(destination: url) {

                    actionLabel(
                        String(localized: "Visit Event Website"),
                        systemImage: "arrow.up.right"
                    )

                }

            }

        }

    }

    @ContentBuilder
    private func actionLabel(_ title: String, systemImage: String) -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

            Text(title)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .frame(maxWidth: .infinity, alignment: .leading)

            RNImageSource.systemImage(systemImage)
                .view(shouldResize: false)

        }
        .runeFont(with: .TITLE_3)
        .runeForeground(.primary)
        .frame(minHeight: 44)
        .contentShape(Rectangle())

    }

}

#Preview {

    if let event = MockCustomerModels.events.first {

        EventDetailsScreen(
            viewModel: mockResolve(EventDetailsViewModel.self)
                .setup(
                    locationId: MockCustomerModels.primaryLocationId,
                    event: event
                )
        )
        .withMockPreviews()

    }

}
