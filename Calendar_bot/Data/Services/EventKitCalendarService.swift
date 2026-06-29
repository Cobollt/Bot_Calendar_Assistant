import EventKit

final class EventKitCalendarService {
    private let eventStore = EKEventStore()
    
    func requestAccess() async throws -> Bool {

        let granted = try await eventStore.requestFullAccessToEvents()

        guard granted else {
            throw CalendarError.accessDenied
        }

        return granted
    }
    
    private func makeEKRecurrenceRule(
        from recurrenceRule: RecurrenceRule
    ) -> EKRecurrenceRule {

        switch recurrenceRule.frequency {

        case .daily:
            return EKRecurrenceRule(
                recurrenceWith: .daily,
                interval: 1,
                end: nil
            )

        case .weekly:
            if let weekday = recurrenceRule.weekday {
                return EKRecurrenceRule(
                    recurrenceWith: .weekly,
                    interval: 1,
                    daysOfTheWeek: [
                        EKRecurrenceDayOfWeek(
                            EKWeekday(rawValue: weekday)!
                        )
                    ],
                    daysOfTheMonth: nil,
                    monthsOfTheYear: nil,
                    weeksOfTheYear: nil,
                    daysOfTheYear: nil,
                    setPositions: nil,
                    end: nil
                )
            }

            return EKRecurrenceRule(
                recurrenceWith: .weekly,
                interval: 1,
                end: nil
            )

        case .monthly:
            return EKRecurrenceRule(
                recurrenceWith: .monthly,
                interval: 1,
                end: nil
            )

        case .yearly:
            return EKRecurrenceRule(
                recurrenceWith: .yearly,
                interval: 1,
                end: nil
            )
        }
    }

    func createEvent(_ event: CalendarEvent) throws {
        
        guard hasCalendarAccess() else {
            throw CalendarError.accessDenied
        }
        
        let ekEvent = EKEvent(eventStore: eventStore)
        
        guard let calendar = findWritableCalendar()
        else {
            throw CalendarError.calendarNotFound
        }

        ekEvent.calendar = calendar
        
        ekEvent.title = event.title
        ekEvent.startDate = event.startDate
        ekEvent.endDate = event.endDate
        ekEvent.notes = event.notes
        
        if let reminder = event.reminder{
            let alarm = EKAlarm(relativeOffset: TimeInterval(-reminder.minutesBefore * 60))
            ekEvent.addAlarm(alarm)
        }
        
        if let recurrenceRule = event.recurrenceRule {
            ekEvent.recurrenceRules = [
                makeEKRecurrenceRule(from: recurrenceRule)
            ]
        }
        
        do {

            try eventStore.save(
                ekEvent,
                span: .thisEvent
            )

        }

        catch {

            throw CalendarError.eventSaveFailed

        }
    }
    
    private func findICloudCalendar() -> EKCalendar? {
        eventStore.calendars(for: .event).first {
            $0.source.sourceType == .calDAV &&
            $0.source.title.lowercased().contains("icloud")
        }
    }
    
    func hasCalendarAccess() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)

        if #available(iOS 17.0, *) {
            return status == .fullAccess
        } else {
            return status == .authorized
        }
    }
    
    private func findWritableCalendar() -> EKCalendar? {

        eventStore.calendars(for: .event).first {
            $0.allowsContentModifications &&
            $0.source.sourceType == .calDAV
        }

        ??

        eventStore.calendars(for: .event).first {
            $0.allowsContentModifications
        }
    }
    
    func findEvents(
        matching text: String?,
        from startDate: Date,
        to endDate: Date
    ) throws -> [CalendarEvent] {

        guard hasCalendarAccess() else {
            throw CalendarError.accessDenied
        }

        let calendars = eventStore.calendars(for: .event)

        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars
        )

        let events = eventStore.events(matching: predicate)

        let filteredEvents: [EKEvent]

        if let text,
           !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            filteredEvents = events.filter {
                $0.title
                    .lowercased()
                    .contains(text.lowercased())
            }

        } else {
            filteredEvents = events
        }

        return filteredEvents.map { ekEvent in
            CalendarEvent(
                id: UUID(),
                externalIdentifier: ekEvent.eventIdentifier,
                title: ekEvent.title,
                startDate: ekEvent.startDate,
                endDate: ekEvent.endDate,
                notes: ekEvent.notes,
                reminder: ekEvent.alarms?.first.map {
                    Reminder(minutesBefore: Int(abs($0.relativeOffset) / 60))
                },
                recurrenceRule: nil
            )
        }
    }
    
    func updateEvent(_ event: CalendarEvent) throws {
        guard hasCalendarAccess() else {
            throw CalendarError.accessDenied
        }

        guard let externalIdentifier = event.externalIdentifier,
              let ekEvent = eventStore.event(withIdentifier: externalIdentifier)
        else {
            throw CalendarError.calendarNotFound
        }

        ekEvent.title = event.title
        ekEvent.startDate = event.startDate
        ekEvent.endDate = event.endDate
        ekEvent.notes = event.notes

        ekEvent.alarms?.forEach {
            ekEvent.removeAlarm($0)
        }

        if let reminder = event.reminder {
            ekEvent.addAlarm(
                EKAlarm(
                    relativeOffset: TimeInterval(-reminder.minutesBefore * 60)
                )
            )
        }

        if let recurrenceRule = event.recurrenceRule {
            ekEvent.recurrenceRules = [
                makeEKRecurrenceRule(from: recurrenceRule)
            ]
        }

        do {
            try eventStore.save(
                ekEvent,
                span: .thisEvent,
                commit: true
            )
        } catch {
            throw CalendarError.eventSaveFailed
        }
    }
    
    func deleteEvent(_ event: CalendarEvent) throws {
        guard hasCalendarAccess() else {
            throw CalendarError.accessDenied
        }

        guard let externalIdentifier = event.externalIdentifier,
              let ekEvent = eventStore.event(withIdentifier: externalIdentifier)
        else {
            throw CalendarError.calendarNotFound
        }

        do {
            try eventStore.remove(
                ekEvent,
                span: .thisEvent,
                commit: true
            )
        } catch {
            throw CalendarError.eventSaveFailed
        }
    }
}
