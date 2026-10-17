import SwiftUI

struct StoreEventCard: View {

    @Environment(\.style) private var style

    let event: StoreEvent
    let location: StoreLocation?
    let onSelect: () -> Void

    private var schedule: StoreEventSchedule {
        StoreEventSchedule(event: self.event, location: self.location)
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
        .frame(height: 160)
        .clipped()

    }

    @ViewBuilder
    private func eventDetails() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            eventTitle()
            scheduleView()

        }
        .padding(.small)

    }

    @ViewBuilder
    private func eventTitle() -> some View {

        Text(self.event.title)
            .appFont(with: .TITLE_3)
            .foregroundStyle(.text(.title))
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)

    }

    @ViewBuilder
    private func scheduleView() -> some View {

        Group {

            if let startsAt = self.schedule.startsAt {
                Text(self.schedule.formattedDate(startsAt))
            } else {
                Text(String(localized: "Date To Be Announced"))
            }

        }
        .appFont(with: .NOTE_1)
        .foregroundStyle(.text(.body))
        .lineLimit(2)
        .frame(maxWidth: .infinity, alignment: .leading)

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
