import Foundation


protocol CalendarRepositoryProtocol {
    func requestAccess() async throws -> Bool
    func createEvent(_ event: CalendarEvent) async throws
}
