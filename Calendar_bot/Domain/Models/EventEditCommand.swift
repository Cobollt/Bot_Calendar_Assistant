import Foundation

enum EventEditAction {
    case reschedule
    case delete
    case updateReminder
}

struct EventEditCommand {
    let action: EventEditAction
    let searchText: String?
    let newDate: Date?
    let timeOffsetMinutes: Int?
    let reminderMinutes: Int?
}
