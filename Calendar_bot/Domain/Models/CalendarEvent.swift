import Foundation


struct CalendarEvent {
    let id: UUID
    let title: String
    let startDate: Date
    let endDate: Date
    let notes: String?
    let reminder: Reminder?
}
