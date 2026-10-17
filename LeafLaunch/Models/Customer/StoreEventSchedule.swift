import Foundation

nonisolated struct StoreEventSchedule: Sendable {

    let startsAt: Date?
    let endsAt: Date?
    let timeZone: TimeZone

    init(event: StoreEvent, location: StoreLocation?) {

        let schedule = event.locations?.first { $0.storeLocationId == location?.id }
        self.startsAt = schedule?.startsAt ?? event.startsAt

        if let schedule {
            self.endsAt = schedule.endsAt
        } else {
            self.endsAt = event.endsAt
        }

        self.timeZone = (schedule?.timezone ?? location?.timezone)
            .flatMap(TimeZone.init(identifier:)) ?? .autoupdatingCurrent

    }

    func formattedDate(_ date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, timeZone: self.timeZone))
    }

}
