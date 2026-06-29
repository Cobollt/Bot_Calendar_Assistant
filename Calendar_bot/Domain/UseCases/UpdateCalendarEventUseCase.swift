import Foundation

final class UpdateCalendarEventUseCase {

    private let calendarRepository: CalendarRepositoryProtocol

    init(calendarRepository: CalendarRepositoryProtocol) {
        self.calendarRepository = calendarRepository
    }

    func execute(_ event: CalendarEvent) async throws {
        try await calendarRepository.updateEvent(event)
    }
}
