import EventKit

final class EventKitCalendarService {
    private let eventStore = EKEventStore()
    
func requestAccess() async throws -> Bool {
    try await eventStore.requestFullAccessToEvents()
    }

    func createEvent(_ event: CalendarEvent) throws {
        let ekEvent = EKEvent(eventStore: eventStore)
        
        ekEvent.title = event.title
        ekEvent.startDate = event.startDate
        ekEvent.endDate = event.endDate
        ekEvent.notes = event.notes
        
        if let reminder = event.reminder{
            let alarm = EKAlarm(relativeOffset: TimeInterval(-reminder.minutesBefore * 60))
            ekEvent.addAlarm(alarm)
        }
        
        ekEvent.calendar = findICloudCalendar()
            ?? eventStore.defaultCalendarForNewEvents
        
        try eventStore.save(ekEvent, span: .thisEvent)
    }
    
    private func findICloudCalendar() -> EKCalendar? {
        eventStore.calendars(for: .event).first {
            $0.source.sourceType == .calDAV &&
            $0.source.title.lowercased().contains("iCloud")
        }
    }
}
