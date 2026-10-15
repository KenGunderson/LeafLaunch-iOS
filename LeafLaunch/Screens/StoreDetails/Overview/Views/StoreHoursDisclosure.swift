import SwiftUI

struct StoreHoursDisclosure: View {

    @Environment(\.style) private var style
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isExpanded = false

    let details: CustomerLocationDetails

    private var hours: [StoreHours] {

        (self.details.location.hours ?? []).sorted {
            ($0.weekday, $0.sequence, $0.id) < ($1.weekday, $1.sequence, $1.id)
        }

    }

    private var exceptions: [ScheduleException] {

        (self.details.location.scheduleExceptions ?? [])
            .filter { $0.localDate >= self.details.localDate }
            .sorted { ($0.localDate, $0.sequence, $0.id) < ($1.localDate, $1.sequence, $1.id) }

    }

    private func weekday(_ value: Int) -> String {

        let symbols = DateFormatter().weekdaySymbols ?? []
        return symbols.indices.contains(value) ? symbols[value] : String(value)

    }

    private func formattedTime(_ value: String?) -> String {

        guard let value else { return String(localized: "Unavailable") }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .gmt
        formatter.dateFormat = value.count > 5 ? "HH:mm:ss" : "HH:mm"
        guard let date = formatter.date(from: value) else { return value }

        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)

    }

    private func formattedDate(_ value: String) -> String {

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .gmt
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: value) else { return value }

        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .medium
        return formatter.string(from: date)

    }

    private func hoursText(closed: Bool, opensAt: String?, closesAt: String?) -> String {

        guard !closed else { return String(localized: "Closed") }
        let interval = "\(formattedTime(opensAt)) - \(formattedTime(closesAt))"

        if let opensAt, let closesAt, closesAt <= opensAt {
            return String(localized: "\(interval) (next day)")
        }

        return interval

    }

    var body: some View {

        DisclosureGroup(isExpanded: self.$isExpanded) {

            VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

                if let timezone = self.details.location.timezone, !timezone.isEmpty {

                    Text(timezone)
                        .appFont(with: .NOTE_1)
                        .foregroundStyle(.text(.body))

                }

                if self.hours.isEmpty {

                    Text(String(localized: "Contact the store for opening hours."))
                        .appFont(with: .BODY_2)
                        .foregroundStyle(.text(.body))

                } else {

                    ForEach(self.hours) { hours in

                        hoursRow(
                            title: weekday(hours.weekday),
                            hours: hoursText(closed: hours.closed, opensAt: hours.opensAt, closesAt: hours.closesAt)
                        )

                    }

                }

                specialHours()

            }
            .padding(.top, .small2)

        } label: {

            HStack(spacing: self.style.spacing(.small2)) {

                ImageSource.systemImage("clock")
                    .view(shouldResize: false)
                    .foregroundStyle(.foreground(.primary))
                    .accessibilityHidden(true)
                Text(String(localized: "Opening hours"))
                    .foregroundStyle(.text(.title))

            }
            .appFont(with: .TITLE_3)
            .padding(.vertical, .small)
            .frame(minHeight: 44)

        }
        .tint(self.style.foreground(.primary).source(style: self.style))
        .animation(self.reduceMotion ? nil : .bouncy, value: self.isExpanded)

    }

    private func hoursRow(title: String, hours: String) -> some View {

        ViewThatFits(in: .horizontal) {

            HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.medium)) {

                Text(title)
                    .foregroundStyle(.text(.title))
                Spacer(minLength: self.style.spacing(.small))
                Text(hours)
                    .foregroundStyle(.text(.body))
                    .monospacedDigit()

            }

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                Text(title)
                    .foregroundStyle(.text(.title))
                Text(hours)
                    .foregroundStyle(.text(.body))
                    .monospacedDigit()

            }

        }
        .appFont(with: .BODY_1)
        .accessibilityElement(children: .combine)

    }

    @ViewBuilder
    private func specialHours() -> some View {

        if !self.exceptions.isEmpty {

            Divider()

            Text(String(localized: "Special hours"))
                .appFont(with: .TITLE_2)
                .foregroundStyle(.text(.title))

            ForEach(self.exceptions) { exception in

                VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                    if let label = exception.label, !label.isEmpty {

                        Text(label)
                            .appFont(with: .TITLE_2)
                            .foregroundStyle(.text(.title))

                    }

                    hoursRow(
                        title: formattedDate(exception.localDate),
                        hours: hoursText(
                            closed: exception.closed,
                            opensAt: exception.opensAt,
                            closesAt: exception.closesAt
                        )
                    )

                }
                .accessibilityElement(children: .combine)

            }

        }

    }

}

#Preview {

    ScrollView {

        StoreHoursDisclosure(details: MockCustomerModels.locationDetails)
            .padding(.medium)

    }
    .withMockPreviews()

}
