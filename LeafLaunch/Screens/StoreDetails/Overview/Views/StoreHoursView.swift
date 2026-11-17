import SwiftUI

struct StoreHoursView: View {

    private struct HolidayHoursDisclosureStyle: DisclosureGroupStyle {

        @Environment(\.style) private var style
        @Environment(\.accessibilityReduceMotion) private var reduceMotion

        @ContentBuilder
        func makeBody(configuration: Configuration) -> some View {

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.cardContent)
            ) {

                header(configuration)

                if configuration.isExpanded {

                    configuration.content
                        .transition(.blurReplace)

                }

            }

        }

        @ContentBuilder
        private func header(_ configuration: Configuration) -> some View {

            Button {

                withAnimation(self.reduceMotion ? nil : .bouncy) {
                    configuration.isExpanded.toggle()
                }

            } label: {

                HStack(spacing: self.style.spacing(LLSpacing.groupedContent)) {

                    configuration.label

                    RNImageSource.systemImage("chevron.down")
                        .view(shouldResize: false)
                        .runeFont(with: .TITLE_2)
                        .runeTextColor(.body)
                        .rotationEffect(.degrees(configuration.isExpanded ? 180 : 0))

                }

            }
            .buttonStyle(.plain)
            .accessibilityValue(configuration.isExpanded ? String(localized: "Expanded") : String(localized: "Collapsed"))

        }

    }

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
        return calendar.component(
            .weekday,
            from: date
        ) - 1

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
                : String(localized: "Special Hours")
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
                includesNextDay: true
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
                includesNextDay: true
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

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.none)
        ) {

            weeklyHoursSection()
            specialHours()

        }

    }

    @ContentBuilder
    private func weeklyHoursSection() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.groupedContent)
        ) {

            Text(String(localized: "Opening Hours"))
                .runeFont(with: LeafLaunchThemeTokens.headingFont)
                .runeTextColor(.title)

            if self.hours.isEmpty {

                Text(String(localized: "Opening Hours Unavailable"))
                    .runeFont(with: .BODY_2)
                    .runeTextColor(.body)

            } else {

                weeklyHours()

            }

        }

    }

    @ContentBuilder
    private func weeklyHours() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.none)
        ) {

            ForEach(1...7, id: \.self) { day in

                weeklyHoursRow(day % 7)

                if day < 7, self.today != day % 7, self.today != (day + 1) % 7 {

                    LLDivider().opacity(0.4)

                }

            }

        }

    }

    @ContentBuilder
    private func weeklyHoursRow(_ day: Int) -> some View {

        hoursRow(
            title: weekday(day),
            hours: hoursText(for: day),
            isToday: self.today == day
        )
        .runePadding(.vertical, LLSpacing.groupedContent)
        .background {

            if self.today == day {

                RoundedRectangle(cornerRadius: self.style.radius(.small))
                    .runeFill(.sourceWithOpacity(
                        .palette(.link),
                        opacity: 0.08,
                        style: self.style
                    ))
                    .runePadding(.horizontal, .custom(-self.style.spacing(LLSpacing.groupedContent)))

            }

        }

    }

    @ContentBuilder
    private func hoursRow(title: String,
                          subtitle: String? = nil,
                          hours: String,
                          isToday: Bool = false) -> some View {

        ViewThatFits(in: .horizontal) {

            HStack(
                alignment: .firstTextBaseline,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                hoursLabel(
                    title,
                    subtitle: subtitle,
                    isToday: isToday
                )
                    .frame(maxWidth: .infinity, alignment: .leading)
                hoursValue(
                    hours,
                    isTrailing: true
                )

            }

            VStack(
                alignment: .leading,
                spacing: self.style.spacing(LLSpacing.metadata)
            ) {

                hoursLabel(
                    title,
                    subtitle: subtitle,
                    isToday: isToday
                )
                hoursValue(
                    hours,
                    isTrailing: false
                )

            }

        }
        .runeFont(with: .BODY_1)

    }

    @ContentBuilder
    private func hoursLabel(_ title: String,
                            subtitle: String?,
                            isToday: Bool) -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.metadata)
        ) {

            HStack(
                alignment: .firstTextBaseline,
                spacing: self.style.spacing(LLSpacing.groupedContent)
            ) {

                Text(title)
                    .runeFont(with: isToday ? .TITLE_2 : .BODY_1)
                    .runeTextColor(.title)

                if isToday {

                    Text(String(localized: "Today"))
                        .runeFont(with: .NOTE_2)
                        .foregroundStyle(RNColorSource.palette(.link))

                }

            }

            if let subtitle {

                Text(subtitle)
                    .runeFont(with: .NOTE_2)
                    .runeTextColor(.body)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

            }

        }

    }

    @ContentBuilder
    private func hoursValue(_ hours: String, isTrailing: Bool) -> some View {

        Text(hours)
            .runeTextColor(.body)
            .monospacedDigit()
            .multilineTextAlignment(isTrailing ? .trailing : .leading)

    }

    @ContentBuilder
    private func specialHours() -> some View {

        if !self.exceptions.isEmpty {

            Group {

                LLDivider()
                    .runePadding(.vertical, LLSpacing.cardContent)

                DisclosureGroup {

                    exceptionRows()

                } label: {

                    StoreInfoActionRow(
                        title: String(localized: "Holiday Hours"),
                        value: self.exceptionSummary,
                        systemImage: "calendar",
                        showsChevron: false
                    )

                }
                .disclosureGroupStyle(HolidayHoursDisclosureStyle())

            }
            .transition(.blurReplace)

        }

    }

    @ContentBuilder
    private func exceptionRows() -> some View {

        VStack(
            alignment: .leading,
            spacing: self.style.spacing(LLSpacing.cardContent)
        ) {

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
            .runePadding(LLSpacing.pageInset)

    }
    .withMockPreviews()

}
