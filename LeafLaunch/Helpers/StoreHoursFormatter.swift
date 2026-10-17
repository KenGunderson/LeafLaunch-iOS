import Foundation

nonisolated enum StoreHoursFormatter {

    static func hours(closed: Bool,
                      opensAt: String?,
                      closesAt: String?,
                      includesNextDay: Bool = true) -> String {

        guard !closed else { return String(localized: "Closed") }
        guard let opensAt, let closesAt else { return String(localized: "Hours unavailable") }

        let interval = "\(formattedTime(opensAt)) – \(formattedTime(closesAt))"

        if includesNextDay, closesAt <= opensAt {
            return String(localized: "\(interval) (next day)")
        }

        return interval

    }

    private static func formattedTime(_ value: String) -> String {

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

}
