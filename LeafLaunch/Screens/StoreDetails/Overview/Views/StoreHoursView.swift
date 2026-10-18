import SwiftUI

struct StoreHoursView: View {

    @Environment(\.style) private var style

    let details: CustomerLocationDetails

    private var hours: [StoreHours] {

        (self.details.location.hours ?? []).sorted {
            ($0.weekday, $0.sequence, $0.id) < ($1.weekday, $1.sequence, $1.id)
        }

    }

    private var today: Int? {

        guard let date = localDate(self.details.localDate) else { return nil }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar.component(.weekday, from: date) - 1

    }

    private var exceptions: [ScheduleException] {

        (self.details.location.scheduleExceptions ?? [])
            .filter { $0.localDate >= self.details.localDate }
            .sorted { ($0.localDate, $0.sequence, $0.id) < ($1.localDate, $1.sequence, $1.id) }

    }

    private var exceptionDates: [String] {
        Array(Set(self.exceptions.map(\.localDate))).sorted()
    }

    private var exceptionSummary: String {

        self.exceptionDates.prefix(2).map { date in

            let intervals = self.exceptions.filter { $0.localDate == date }
            let status = intervals.allSatisfy(\.closed)
                ? String(localized: "Closed")
                : String(localized: "Special hours")
            return "\(formattedDate(date, isCompact: true)) · \(status)"

        }
        .joined(separator: "\n")

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

    private func localDate(_ value: String) -> Date? {

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .gmt
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)

    }

    private func formattedDate(_ value: String, isCompact: Bool = false) -> String {

        guard let date = localDate(value) else { return value }

        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .gmt

        if isCompact {
            formatter.setLocalizedDateFormatFromTemplate("MMM d")
        } else {
            formatter.dateStyle = .medium
        }

        return formatter.string(from: date)

    }

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {

            weeklyHoursSection()
            specialHours()

        }

    }

    @ViewBuilder
    private func weeklyHoursSection() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            Text(String(localized: "Store hours"))
                .appFont(with: .TITLE_6)
                .foregroundStyle(self.style.textColor(.title))

            if self.hours.isEmpty {

                Text(String(localized: "Opening Hours Unavailable"))
                    .appFont(with: .BODY_2)
                    .foregroundStyle(self.style.textColor(.body))

            } else {

                weeklyHours()

            }

        }

    }

    @ViewBuilder
    private func weeklyHours() -> some View {

        VStack(alignment: .leading, spacing: 0) {

            ForEach(1...7, id: \.self) { day in

                weeklyHoursRow(day % 7)

                if day < 7, self.today != day % 7, self.today != (day + 1) % 7 {

                    Divider()
                        .overlay(self.style.background(.border))

                }

            }

        }

    }

    @ViewBuilder
    private func weeklyHoursRow(_ day: Int) -> some View {

        hoursRow(
            title: weekday(day),
            hours: hoursText(for: day),
            isToday: self.today == day
        )
        .padding(.vertical, .extraSmall)
        .background {

            if self.today == day {

                RoundedRectangle(cornerRadius: self.style.radius(.medium))
                    .fill(self.style.palette(.link).opacity(0.08))
                    .padding(.horizontal, -self.style.spacing(.small))

            }

        }

    }

    @ViewBuilder
    private func hoursRow(title: String,
                          subtitle: String? = nil,
                          hours: String,
                          isToday: Bool = false) -> some View {

        ViewThatFits(in: .horizontal) {

            HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.small)) {

                hoursLabel(title, subtitle: subtitle, isToday: isToday)
                Spacer(minLength: self.style.spacing(.small))
                hoursValue(hours, isTrailing: true)

            }

            VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

                hoursLabel(title, subtitle: subtitle, isToday: isToday)
                hoursValue(hours, isTrailing: false)

            }

        }
        .appFont(with: .BODY_2)

    }

    @ViewBuilder
    private func hoursLabel(_ title: String, subtitle: String?, isToday: Bool) -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.extraSmall)) {

            HStack(alignment: .firstTextBaseline, spacing: self.style.spacing(.small)) {

                Text(title)
                    .appFont(with: isToday ? .TITLE_3 : .BODY_2)
                    .foregroundStyle(self.style.textColor(.title))

                if isToday {

                    Text(String(localized: "Today"))
                        .appFont(with: .TITLE_2)
                        .foregroundStyle(self.style.palette(.link))

                }

            }

            if let subtitle {

                Text(subtitle)
                    .appFont(with: .NOTE_1)
                    .foregroundStyle(self.style.textColor(.body))
                    .fixedSize(horizontal: false, vertical: true)

            }

        }

    }

    @ViewBuilder
    private func hoursValue(_ hours: String, isTrailing: Bool) -> some View {

        Text(hours)
            .foregroundStyle(self.style.textColor(.body))
            .monospacedDigit()
            .multilineTextAlignment(isTrailing ? .trailing : .leading)

    }

    @ViewBuilder
    private func specialHours() -> some View {

        if !self.exceptions.isEmpty {

            Divider()
                .overlay(self.style.background(.border))
                .padding(.vertical, .small2)

            DisclosureGroup {

                exceptionRows()
                    .padding(.top, .small2)

            } label: {

                StoreInfoActionRow(
                    title: String(localized: "Holiday hours"),
                    value: self.exceptionSummary,
                    systemImage: "calendar",
                    showsChevron: false
                )

            }
            .tint(self.style.textColor(.body).resolvedColor(style: self.style))

        }

    }

    @ViewBuilder
    private func exceptionRows() -> some View {

        VStack(alignment: .leading, spacing: self.style.spacing(.small2)) {

            ForEach(self.exceptionDates, id: \.self) { date in

                hoursRow(
                    title: formattedDate(date),
                    subtitle: exceptionLabel(for: date),
                    hours: exceptionHours(for: date)
                )

            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)

    }

}

#Preview {

    ScrollView {

        StoreHoursView(details: MockCustomerModels.locationDetails)
            .padding(.medium)

    }
    .withMockPreviews()

}
