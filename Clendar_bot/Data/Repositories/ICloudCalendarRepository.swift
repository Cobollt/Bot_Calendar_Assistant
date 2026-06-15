import Foundation

final class ICloudCalendarRepository: CalendarRepositoryProtocol {

    private let calendarService: EventKitCalendarService

    init(calendarService: EventKitCalendarService) {
        self.calendarService = calendarService
    }

    func requestAccess() async throws -> Bool {
        try await calendarService.requestAccess()
    }

    func createEvent(_ event: CalendarEvent) async throws {
        try calendarService.createEvent(event)
    }
    
    func hasCalendarAccess() -> Bool {
        calendarService.hasCalendarAccess()
    }
}
