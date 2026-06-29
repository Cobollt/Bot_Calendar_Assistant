import Foundation

protocol CalendarRepositoryProtocol {
    func requestAccess() async throws -> Bool
    func hasCalendarAccess() -> Bool

    func createEvent(_ event: CalendarEvent) async throws

    func findEvents(
        matching text: String?,
        from startDate: Date,
        to endDate: Date
    ) async throws -> [CalendarEvent]

    func deleteEvent(_ event: CalendarEvent) async throws

    func updateEvent(_ event: CalendarEvent) async throws
}
