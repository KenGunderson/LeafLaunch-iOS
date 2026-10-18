import SwiftUI

struct StoreEventCard: View {

    @Environment(\.style) private var style

    let event: StoreEvent
    let location: StoreLocation?
    let onSelect: () -> Void

    private var schedule: StoreEventSchedule {
        StoreEventSchedule(event: self.event, location: self.location)
    }

    private var scheduleDescription: String {

        guard let startsAt = self.schedule.startsAt else {
            return String(localized: "Date To Be Announced")
        }

        let time = startsAt.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened, timeZone: self.schedule.timeZone)
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

            VStack(alignment: .leading, spacing: 0) {

                eventImage()
                eventDetails()

            }

        }
        .contentShape(Rectangle())
        .asButton(action: self.onSelect)

    }

    @ViewBuilder
    private func eventImage() -> some View {

        StoreMarketingImage(
            url: self.event.image?.url,
            placeholder: ImageResource(name: "StoreEventFallback", bundle: .main)
        )
        .frame(maxWidth: .infinity)
        .frame(height: 104)
        .clipped()

    }

    @ViewBuilder
    private func eventDetails() -> some View {

        HStack(spacing: self.style.spacing(.small2)) {

            dateBadge()
            dateDivider()
            eventCaption()
            disclosureIndicator()

        }
        .padding(.small)

    }

    @ViewBuilder
    private func dateBadge() -> some View {

        VStack(spacing: 0) {

            if let startsAt = self.schedule.startsAt {

                Text(startsAt.formatted(
                    Date.FormatStyle(date: .omitted, time: .omitted, timeZone: self.schedule.timeZone)
                        .month(.abbreviated)
                ))
                .appFont(with: .NOTE_2)
                .textCase(.uppercase)
                .foregroundStyle(.text(.body))

                Text(startsAt.formatted(
                    Date.FormatStyle(date: .omitted, time: .omitted, timeZone: self.schedule.timeZone)
                        .day()
                ))
                .appFont(with: .HEADER_3)
                .foregroundStyle(.text(.title))

            } else {

                ImageSource.systemImage("calendar")
                    .view(shouldResize: false)
                    .foregroundStyle(.text(.body))

                Text(String(localized: "TBA"))
                    .appFont(with: .TITLE_2)
                    .foregroundStyle(.text(.title))

            }

        }
        .frame(width: self.style.spacing(.large2))
        .fixedSize(horizontal: false, vertical: true)

    }

    @ViewBuilder
    private func dateDivider() -> some View {

        Rectangle()
            .fill(self.style.background(.border))
            .frame(width: 1, height: self.style.spacing(.large2))

    }

    @ViewBuilder
    private func eventCaption() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            Text(self.event.title)
                .appFont(with: .TITLE_3)
                .foregroundStyle(.text(.title))
                .lineLimit(2)

            Text(self.scheduleDescription)
                .appFont(with: .NOTE_2)
                .foregroundStyle(.text(.body))
                .lineLimit(1)

        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func disclosureIndicator() -> some View {

        ImageSource.systemImage("chevron.right")
            .view(shouldResize: false)
            .appFont(with: .TITLE_2)
            .foregroundStyle(self.style.foreground(.tertiary))

    }

}

#Preview {

    if let event = MockCustomerModels.events.first {

        StoreEventCard(event: event, location: MockCustomerModels.locationDetails.location, onSelect: {})
            .frame(width: 240)
            .padding(.medium)
            .withMockPreviews()

    }

}
