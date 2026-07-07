import Foundation

struct EventEditRequest {
    let newTitle: String?
    let newStartDate: Date?
    let newEndDate: Date?
    let newReminder: Reminder?
    let shouldRemoveReminder: Bool
    let newRecurrence: RecurrenceRule?
    let shouldRemoveRecurrence: Bool
    let newNotes: String?
}

extension EventEditRequest {

    static var empty: EventEditRequest {
        EventEditRequest(
            newTitle: nil,
            newStartDate: nil,
            newEndDate: nil,
            newReminder: nil,
            shouldRemoveReminder: false,
            newRecurrence: nil,
            shouldRemoveRecurrence: false,
            newNotes: nil
        )
    }

    var hasChanges: Bool {
        newTitle != nil ||
        newStartDate != nil ||
        newEndDate != nil ||
        newReminder != nil ||
        shouldRemoveReminder ||
        newRecurrence != nil ||
        shouldRemoveRecurrence ||
        newNotes != nil
    }
}
