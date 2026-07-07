import Foundation

final class HomeEditEventFlow {

    private let findCalendarEventsUseCase: FindCalendarEventsUseCase
    private let settingsService: SettingsServiceProtocol
    private let editRequestParser: EventEditRequestParserService
    private let editApplier: EventEditApplierService

    init(
        findCalendarEventsUseCase: FindCalendarEventsUseCase,
        settingsService: SettingsServiceProtocol,
        editRequestParser: EventEditRequestParserService,
        editApplier: EventEditApplierService
    ) {
        self.findCalendarEventsUseCase = findCalendarEventsUseCase
        self.settingsService = settingsService
        self.editRequestParser = editRequestParser
        self.editApplier = editApplier
    }

    func prepare(from command: VoiceCommand) async throws -> HomePendingAction? {
        let text = command.rawText.lowercased()
        let settings = settingsService.getSettings()

        let editRequest = editRequestParser.parse(
            from: text,
            settings: settings
        )

        guard editRequest.hasChanges else {
            return nil
        }

        let searchText = makeSearchText(from: text)

        guard let event = try await findFirstEvent(matching: searchText) else {
            return nil
        }

        let updatedEvent = editApplier.apply(
            request: editRequest,
            to: event
        )

        return .move(
            updatedEvent,
            EventPresentationMapper.map(updatedEvent)
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

    private func makeSearchText(from text: String) -> String {
        var result = text

        let patterns = [
            #"(?i)\bперенеси\b"#,
            #"(?i)\bперенести\b"#,
            #"(?i)\bперемести\b"#,
            #"(?i)\bпереместить\b"#,
            #"(?i)\bсдвинь\b"#,
            #"(?i)\bсдвинуть\b"#,

            #"(?i)\bизмени\b"#,
            #"(?i)\bизменить\b"#,
            #"(?i)\bпоменяй\b"#,
            #"(?i)\bпоменять\b"#,
            #"(?i)\bпереименуй\b"#,
            #"(?i)\bпереименовать\b"#,
            #"(?i)\bназови\b"#,
            #"(?i)\bназвать\b"#,

            #"(?i)\bсобытие\b"#,
            #"(?i)\bвстречу\b"#,
            #"(?i)\bвстреча\b"#,
            #"(?i)\bнапоминание\b"#,
            #"(?i)\bуведомление\b"#,
            #"(?i)\bповторение\b"#,

            #"(?i)\bна\s+час\s+позже\b"#,
            #"(?i)\bна\s+час\s+раньше\b"#,
            #"(?i)\bна\s+30\s+минут\s+позже\b"#,
            #"(?i)\bна\s+30\s+минут\s+раньше\b"#,

            #"(?i)\bза\s+час\b"#,
            #"(?i)\bза\s+полчаса\b"#,
            #"(?i)\bза\s+день\b"#,
            #"(?i)\bбез\s+напоминания\b"#,
            #"(?i)\bубери\s+напоминание\b"#,
            #"(?i)\bудали\s+напоминание\b"#,

            #"(?i)\bубери\s+повторение\b"#,
            #"(?i)\bудали\s+повторение\b"#,
            #"(?i)\bбез\s+повторения\b"#,

            #"(?i)\bсегодня\b"#,
            #"(?i)\bзавтра\b"#,
            #"(?i)\bпослезавтра\b"#,

            #"(?i)\b\d{1,2}\s+(?:числа|число)\b"#,
            #"(?i)\b\d{1,2}[./-]\d{1,2}(?:[./-]\d{2,4})?\b"#,
            #"(?i)\b\d{1,2}\s+(?:января|февраля|марта|апреля|мая|июня|июля|августа|сентября|октября|ноября|декабря)(?:\s+\d{4})?\b"#,

            #"(?i)\b(?:следующий|следующую)?\s*(?:понедельник|вторник|среду|среда|четверг|пятницу|пятница|субботу|суббота|воскресенье)\b"#,

            #"(?i)\bв\s+\d{1,2}[:.]\d{2}\b"#,
            #"(?i)\bв\s+\d{1,2}\b"#
        ]

        for pattern in patterns {
            result = result.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        return result
            .replacingOccurrences(
                of: #"\s+"#,
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
