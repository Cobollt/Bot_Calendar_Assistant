import Foundation

final class FindCalendarEventsUseCase {

    private let calendarRepository: CalendarRepositoryProtocol

    init(calendarRepository: CalendarRepositoryProtocol) {
        self.calendarRepository = calendarRepository
    }

    func execute(
        matching text: String?,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [CalendarEvent] {
        try await calendarRepository.findEvents(
            matching: text,
            from: startDate,
            to: endDate
        )
    }
}
