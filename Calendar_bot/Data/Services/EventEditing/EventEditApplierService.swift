import Foundation

final class EventEditApplierService {

    func apply(
        request: EventEditRequest,
        to event: CalendarEvent
    ) -> CalendarEvent {
        let duration = event.endDate.timeIntervalSince(event.startDate)

        let startDate = request.newStartDate ?? event.startDate

        let endDate: Date

        if let newEndDate = request.newEndDate {
            endDate = newEndDate
        } else if request.newStartDate != nil {
            endDate = startDate.addingTimeInterval(duration)
        } else {
            endDate = event.endDate
        }

        let reminder: Reminder?

        if request.shouldRemoveReminder {
            reminder = nil
        } else {
            reminder = request.newReminder ?? event.reminder
        }

        let recurrenceRule: RecurrenceRule?

        if request.shouldRemoveRecurrence {
            recurrenceRule = nil
        } else {
            recurrenceRule = request.newRecurrence ?? event.recurrenceRule
        }

        return CalendarEvent(
            id: event.id,
            externalIdentifier: event.externalIdentifier,
            title: request.newTitle ?? event.title,
            startDate: startDate,
            endDate: endDate,
            notes: request.newNotes ?? event.notes,
            reminder: reminder,
            recurrenceRule: recurrenceRule
        )
    }
}
