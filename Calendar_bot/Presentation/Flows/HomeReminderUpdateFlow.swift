import Foundation

final class HomeReminderUpdateFlow {

    private let findCalendarEventsUseCase: FindCalendarEventsUseCase

    init(
        findCalendarEventsUseCase: FindCalendarEventsUseCase
    ) {
        self.findCalendarEventsUseCase = findCalendarEventsUseCase
    }

    func prepare(from command: VoiceCommand) async throws -> (HomePendingAction?, String?) {
        guard let reminderMinutes = HomeEventCommandMapper
            .extractReminderMinutes(from: command.rawText)
        else {
            return (nil, "Не удалось определить новое время напоминания")
        }

        let searchText = HomeEventCommandMapper.makeReminderSearchText(
            from: command.rawText
        )

        guard let event = try await findFirstEvent(matching: searchText) else {
            return (nil, "Событие для изменения напоминания не найдено")
        }

        let updatedEvent = CalendarEvent(
            id: event.id,
            externalIdentifier: event.externalIdentifier,
            title: event.title,
            startDate: event.startDate,
            endDate: event.endDate,
            notes: event.notes,
            reminder: reminderMinutes == 0
                ? nil
                : Reminder(minutesBefore: reminderMinutes),
            recurrenceRule: event.recurrenceRule
        )

        return (
            .updateReminder(
                updatedEvent,
                EventPresentationMapper.map(updatedEvent)
            ),
            nil
        )
    }

    private func findFirstEvent(
        matching text: String?
    ) async throws -> CalendarEvent? {
        let calendar = Calendar.current
        let now = Date()
        let endDate = calendar.date(
            byAdding: .day,
            value: 60,
            to: now
        ) ?? now

        let events = try await findCalendarEventsUseCase.execute(
            matching: text,
            from: now,
            to: endDate
        )

        return events.first
    }
}
