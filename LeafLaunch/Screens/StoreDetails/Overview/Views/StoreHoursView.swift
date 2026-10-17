import SwiftUI

struct StoreHoursView: View {

    @Environment(\.style) private var style

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

    private var exceptionDates: [String] {
        Array(Set(self.exceptions.map(\.localDate))).sorted()
    }

    private func weekday(_ value: Int) -> String {

        let symbols = DateFormatter().weekdaySymbols ?? []
        return symbols.indices.contains(value) ? symbols[value] : String(value)

    }

    private func hoursText(for weekday: Int) -> String {

        let intervals = self.hours.filter { $0.weekday == weekday }
        guard !intervals.isEmpty else { return String(localized: "Hours Unavailable") }

        return intervals.map {

            StoreHoursFormatter.hours(
                closed: $0.closed,
                opensAt: $0.opensAt,
                closesAt: $0.closesAt,
                includesNextDay: false
            )

        }
        .joined(separator: "\n")

    }

    private func exceptionHours(for date: String) -> String {

        self.exceptions.filter { $0.localDate == date }.map {

            StoreHoursFormatter.hours(
                closed: $0.closed,
                opensAt: $0.opensAt,
                closesAt: $0.closesAt,
                includesNextDay: false
            )

        }
        .joined(separator: "\n")

    }

    private func exceptionLabel(for date: String) -> String? {

        let labels = self.exceptions
            .filter { $0.localDate == date }
            .compactMap { $0.label?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let label = Set(labels).sorted().joined(separator: " · ")
        return label.isEmpty ? nil : label

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

    var body: some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

            if self.hours.isEmpty {

                Text(String(localized: "Opening Hours Unavailable"))
                    .appFont(with: .BODY_2)

            } else {

                weeklyHours()

            }

            specialHours()

        }
        .foregroundStyle(Color.black)

    }

    @ViewBuilder
    private func weeklyHours() -> some View {

        VStack(alignment: .leading, spacing: 0) {

            ForEach(1...7, id: \.self) { day in

                hoursRow(
                    title: weekday(day % 7),
                    hours: hoursText(for: day % 7)
                )

            }

        }

    }

    @ViewBuilder
    private func hoursRow(title: String, subtitle: String? = nil, hours: String) -> some View {

        ViewThatFits(in: .horizontal) {

            HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.small)) {

                hoursLabel(title, subtitle: subtitle)
                Spacer(minLength: self.style.spacing(.small))
                Text(hours)
                    .monospacedDigit()
                    .multilineTextAlignment(.trailing)

            }

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                hoursLabel(title, subtitle: subtitle)
                Text(hours)
                    .monospacedDigit()

            }

        }
        .appFont(with: .BODY_2)

    }

    @ViewBuilder
    private func hoursLabel(_ title: String, subtitle: String?) -> some View {

        VStack(alignment: .leading, spacing: 0) {

            Text(title)

            if let subtitle {

                Text(subtitle)
                    .appFont(with: .NOTE_1)
                    .fixedSize(horizontal: false, vertical: true)

            }

        }

    }

    @ViewBuilder
    private func specialHours() -> some View {

        if !self.exceptions.isEmpty {

            VStack(alignment: .leading, spacing: self.style.spacing(.small)) {

                Divider()

                Text(String(localized: "Special Hours"))
                    .appFont(with: .TITLE_2)

                exceptionRows()

            }

        }

    }

    @ViewBuilder
    private func exceptionRows() -> some View {

        VStack(alignment: .leading, spacing: 0) {

            ForEach(self.exceptionDates, id: \.self) { date in

                hoursRow(
                    title: formattedDate(date),
                    subtitle: exceptionLabel(for: date),
                    hours: exceptionHours(for: date)
                )

            }

        }

    }

}

#Preview {

    ScrollView {

        StoreHoursView(details: MockCustomerModels.locationDetails)
            .padding(.medium)
            .background(Color.white)

    }
    .withMockPreviews()

}
