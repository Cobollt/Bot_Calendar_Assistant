import Foundation

protocol NotificationServiceProtocol {
    func requestAccess() async throws -> Bool
    func scheduleNotification(for event: CalendarEvent) async throws
}
