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
    
    func findEvents(
        matching text: String?,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [CalendarEvent] {
        try calendarService.findEvents(
            matching: text,
            from: startDate,
            to: endDate
        )
    }
    
    func deleteEvent(_ event: CalendarEvent) async throws {
        try calendarService.deleteEvent(event)
    }
    
    func updateEvent(_ event: CalendarEvent) async throws {
        try calendarService.updateEvent(event)
    }
}
