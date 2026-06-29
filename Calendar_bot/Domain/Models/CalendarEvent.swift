import Foundation

struct CalendarEvent {
    let id: UUID
    let externalIdentifier: String?
    let title: String
    let startDate: Date
    let endDate: Date
    let notes: String?
    let reminder: Reminder?
    let recurrenceRule: RecurrenceRule?
}
