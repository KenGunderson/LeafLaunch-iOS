import SwiftUI

struct StoreEventCard: View {

    @Environment(\.style) private var style

    let event: StoreEvent
    let location: StoreLocation?

    private var schedule: EventLocation? {
        self.event.locations?.first { $0.storeLocationId == self.location?.id }
    }

    private var startsAt: Date? {
        self.schedule?.startsAt ?? self.event.startsAt
    }

    private var endsAt: Date? {

        if let schedule = self.schedule {
            return schedule.endsAt
        }

        return self.event.endsAt

    }

    private var timeZone: TimeZone {
        (self.schedule?.timezone ?? self.location?.timezone).flatMap(TimeZone.init(identifier:)) ?? .autoupdatingCurrent
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: self.timeZone))
    }

    private func formattedMonth(_ date: Date) -> String {

        var format = Date.FormatStyle().month(.abbreviated)
        format.timeZone = self.timeZone
        return date.formatted(format)

    }

    private func formattedDay(_ date: Date) -> String {

        var format = Date.FormatStyle().day()
        format.timeZone = self.timeZone
        return date.formatted(format)

    }

    var body: some View {

        AppCardView(
            verticalPadding: .none,
            horizontalPadding: .none,
            cornerRadius: .large,
            shadow: .card
        ) {

            VStack(alignment: .leading, spacing: 0) {

                if let imageURL = self.event.image?.url {

                    ImageSource.remote(
                        url: imageURL,
                        contentMode: .fill,
                        placeholder: AnyView(Rectangle().fill(.background(.tertiary)))
                    )
                    .view()
                    .aspectRatio(1.8, contentMode: .fit)
                    .clipped()
                    .accessibilityHidden(true)

                }

                VStack(alignment: .leading, spacing: self.style.spacing(.medium)) {

                    HStack(alignment: .top, spacing: self.style.spacing(.medium)) {

                        if let startsAt = self.startsAt {
                            dateTile(startsAt)
                        }

                        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                            Text(self.event.title)
                                .appFont(with: .TITLE_5)
                                .foregroundStyle(.text(.title))
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityAddTraits(.isHeader)

                            if let location = self.location {

                                HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.extraSmall)) {

                                    ImageSource.systemImage("mappin.and.ellipse")
                                        .view(shouldResize: false)
                                        .accessibilityHidden(true)
                                    Text(location.name)

                                }
                                .appFont(with: .NOTE_1)
                                .foregroundStyle(.text(.body))

                            }

                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                    }

                    scheduleView()

                    if let description = self.event.description, !description.isEmpty {

                        Text(description)
                            .appFont(with: .BODY_2)
                            .foregroundStyle(.text(.body))
                            .fixedSize(horizontal: false, vertical: true)

                    }

                    if let externalURL = self.event.externalURL {

                        Divider()

                        Link(destination: externalURL) {

                            HStack(spacing: self.style.spacing(.small)) {

                                Text(String(localized: "Event Details"))
                                Spacer(minLength: self.style.spacing(.small))
                                ImageSource.systemImage("arrow.up.right")
                                    .view(shouldResize: false)
                                    .accessibilityHidden(true)

                            }
                            .appFont(with: .TITLE_3)
                            .foregroundStyle(.foreground(.primary))
                            .padding(.vertical, .small)
                            .frame(minHeight: 44)
                            .contentShape(Rectangle())

                        }

                    }

                }
                .padding(.medium)

            }

        }

    }

    private func dateTile(_ date: Date) -> some View {

        VStack(spacing: self.style.spacing(.extraSmall)) {

            Text(formattedMonth(date))
                .appFont(with: .TITLE_2)
            Text(formattedDay(date))
                .appFont(with: .HEADER_3)
                .monospacedDigit()

        }
        .foregroundStyle(.foreground(.primary))
        .padding(.small2)
        .background(.background(.tertiary))
        .clipShape(RoundedRectangle(cornerRadius: self.style.radius(.medium)))
        .accessibilityHidden(true)

    }

    private func scheduleView() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            if let startsAt = self.startsAt {
                Text(String(localized: "Starts \(formattedDate(startsAt))"))
            } else {
                Text(String(localized: "Date to be announced"))
            }

            if let endsAt = self.endsAt {
                Text(String(localized: "Ends \(formattedDate(endsAt))"))
            }

            if self.startsAt != nil {
                Text(self.timeZone.identifier)
            }

        }
        .appFont(with: .NOTE_1)
        .foregroundStyle(.text(.body))
        .fixedSize(horizontal: false, vertical: true)

    }

}

#Preview {

    if let event = MockCustomerModels.events.first {

        ScrollView {

            StoreEventCard(event: event, location: MockCustomerModels.locationDetails.location)
                .padding(.medium)

        }
        .withMockPreviews()

    }

}
