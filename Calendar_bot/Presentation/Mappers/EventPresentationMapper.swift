import Foundation

enum EventPresentationMapper {

    static func map(_ event: CalendarEvent) -> EventPresentation {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateStyle = .medium

        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "ru_RU")
        timeFormatter.dateFormat = "HH:mm"

        let reminderText: String
        
        let recurrenceText: String

        if let recurrenceRule = event.recurrenceRule {
            switch recurrenceRule.frequency {
            case .daily:
                recurrenceText = "Каждый день"
            case .weekly:
                recurrenceText = "Каждую неделю"
            case .monthly:
                recurrenceText = "Каждый месяц"
            case .yearly:
                recurrenceText = "Каждый год"
            }
        } else {
            recurrenceText = "Без повторения"
        }

        if let reminder = event.reminder {
            reminderText = "За \(reminder.minutesBefore) мин."
        } else {
            reminderText = "Без напоминания"
        }

        return EventPresentation(
            title: event.title,
            date: dateFormatter.string(from: event.startDate),
            time: timeFormatter.string(from: event.startDate),
            reminder: reminderText,
            recurrence: recurrenceText
        )
    }
}
