import Foundation

enum HomePendingAction {
    case none
    case create(CalendarEvent, EventPresentation)
    case delete(CalendarEvent, EventPresentation)
    case move(CalendarEvent, EventPresentation)
    case updateReminder(CalendarEvent, EventPresentation)

    var event: CalendarEvent? {
        switch self {
        case .none:
            return nil
        case .create(let event, _),
             .delete(let event, _),
             .move(let event, _),
             .updateReminder(let event, _):
            return event
        }
    }

    var preview: EventPresentation? {
        switch self {
        case .none:
            return nil
        case .create(_, let preview),
             .delete(_, let preview),
             .move(_, let preview),
             .updateReminder(_, let preview):
            return preview
        }
    }

    var isEmpty: Bool {
        if case .none = self {
            return true
        }

        return false
    }
}
