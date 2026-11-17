import SwiftUI

struct StoreEventCard: View {

    @Environment(\.style) private var style

    let event: StoreEvent
    let location: StoreLocation?
    let onSelect: () -> Void

    private var schedule: StoreEventSchedule {
        StoreEventSchedule(
            event: self.event,
            location: self.location
        )
    }

    private var scheduleDescription: String {

        guard let startsAt = self.schedule.startsAt else {
            return String(localized: "Date To Be Announced")
        }

        let time = startsAt.formatted(
            Date.FormatStyle(
                date: .omitted,
                time: .shortened,
                timeZone: self.schedule.timeZone
            )
        )

        return [time, self.location?.name]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")

    }

    var body: some View {

        LLAppCardView(
            verticalPadding: .none,
            horizontalPadding: .none,
            cornerRadius: .large
        ) {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.none)
            ) {

                eventImage()
                eventDetails()

            }

        }
        .contentShape(Rectangle())
        .runeAsButton(action: self.onSelect)

    }

    @ContentBuilder
    private func eventImage() -> some View {

        StoreMarketingImage(
            url: self.event.image?.url,
            placeholder: ImageResource(
                name: "StoreEventFallback",
                bundle: .main
            )
        )
        .frame(maxWidth: .infinity)
        .frame(height: 104)
        .clipped()

    }

    @ContentBuilder
    private func eventDetails() -> some View {

        HStack(spacing: self.style.spacing(LLSpacing.cardContent)) {

            dateBadge()
            dateDivider()
            eventCaption()
            disclosureIndicator()

        }
        .runePadding(.horizontal, LLSpacing.cardContent)
        .runePadding(.vertical, LLSpacing.groupedContent)

    }

    @ContentBuilder
    private func dateBadge() -> some View {

        VStack(spacing: self.style.spacing(LLSpacing.none)) {

            if let startsAt = self.schedule.startsAt {

                Text(startsAt.formatted(
                    Date.FormatStyle(
                        date: .omitted,
                        time: .omitted,
                        timeZone: self.schedule.timeZone
                    )
                        .month(.abbreviated)
                ))
                .runeFont(with: .NOTE_2)
                .textCase(.uppercase)
                .runeTextColor(.body)

                Text(startsAt.formatted(
                    Date.FormatStyle(
                        date: .omitted,
                        time: .omitted,
                        timeZone: self.schedule.timeZone
                    )
                        .day()
                ))
                .runeFont(with: .HEADER_3)
                .runeTextColor(.title)

            } else {

                RNImageSource.systemImage("calendar")
                    .view(shouldResize: false)
                    .runeTextColor(.body)

                Text(String(localized: "TBA"))
                    .runeFont(with: .TITLE_2)
                    .runeTextColor(.title)

            }

        }
        .fixedSize(
            horizontal: true,
            vertical: true
        )

    }

    @ContentBuilder
    private func dateDivider() -> some View {

        Rectangle()
            .runeFill(RNColorSource.background(.border))
            .frame(
                width: 1,
                height: self.style.spacing(.large2)
            )

    }

    @ContentBuilder
    private func eventCaption() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            Text(self.event.title)
                .runeFont(with: .TITLE_3)
                .runeTextColor(.title)
                .lineLimit(2)

            Text(self.scheduleDescription)
                .runeFont(with: .NOTE_2)
                .runeTextColor(.body)
                .lineLimit(1)

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ContentBuilder
    private func disclosureIndicator() -> some View {

        RNImageSource.systemImage("chevron.right")
            .view(shouldResize: false)
            .runeFont(with: .TITLE_2)
            .runeForeground(.tertiary)

    }

}

#Preview {

    if let event = MockCustomerModels.events.first {

        StoreEventCard(
            event: event,
            location: MockCustomerModels.locationDetails.location,
            onSelect: {}
        )
            .frame(width: 240)
            .runePadding(LLSpacing.pageInset)
            .withMockPreviews()

    }

}
