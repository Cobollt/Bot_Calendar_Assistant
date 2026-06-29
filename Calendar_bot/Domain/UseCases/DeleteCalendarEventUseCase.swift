import Foundation

final class DeleteCalendarEventUseCase {

    private let calendarRepository: CalendarRepositoryProtocol

    init(calendarRepository: CalendarRepositoryProtocol) {
        self.calendarRepository = calendarRepository
    }

    func execute(_ event: CalendarEvent) async throws {
        try await calendarRepository.deleteEvent(event)
    }
}
