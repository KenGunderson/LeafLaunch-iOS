import Foundation

nonisolated struct CustomerLocationDetails: Codable, Sendable {

    let location: StoreLocation
    let agePolicy: EffectiveAgePolicy
    let openNow: Bool
    let localDate: String
    let mapsAddress: String

    var address: String {

        let mapsAddress = self.mapsAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        return mapsAddress.isEmpty ? self.location.address : mapsAddress

    }

    var todayHoursDescription: String {

        let exceptions = (self.location.scheduleExceptions ?? [])
            .filter { $0.localDate == self.localDate }
            .sorted { ($0.sequence, $0.id) < ($1.sequence, $1.id) }

        if !exceptions.isEmpty {

            return exceptions.map {
                StoreHoursFormatter.hours(closed: $0.closed, opensAt: $0.opensAt, closesAt: $0.closesAt)
            }
            .joined(separator: ", ")

        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .gmt
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: self.localDate) else {
            return String(localized: "Hours unavailable")
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        let weekday = calendar.component(.weekday, from: date) - 1
        let hours = (self.location.hours ?? [])
            .filter { $0.weekday == weekday }
            .sorted { ($0.sequence, $0.id) < ($1.sequence, $1.id) }

        guard !hours.isEmpty else { return String(localized: "Hours unavailable") }

        return hours.map {
            StoreHoursFormatter.hours(closed: $0.closed, opensAt: $0.opensAt, closesAt: $0.closesAt)
        }
        .joined(separator: ", ")

    }

    private enum CodingKeys: String, CodingKey {

        case location
        case agePolicy = "age_policy"
        case openNow = "open_now"
        case localDate = "local_date"
        case mapsAddress = "maps_address"

    }

}
