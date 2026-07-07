import Foundation

final class EventEditRequestParserService {

    private let dateParser: DateParserService
    private let recurrenceParser: RecurrenceParserService

    init(
        dateParser: DateParserService,
        recurrenceParser: RecurrenceParserService
    ) {
        self.dateParser = dateParser
        self.recurrenceParser = recurrenceParser
    }

    func parse(
        from text: String,
        settings: AppSettings
    ) -> EventEditRequest {
        let normalizedText = text.lowercased()

        return EventEditRequest(
            newTitle: extractNewTitle(from: normalizedText),
            newStartDate: extractNewStartDate(
                from: normalizedText,
                settings: settings
            ),
            newEndDate: nil,
            newReminder: extractNewReminder(from: normalizedText),
            shouldRemoveReminder: shouldRemoveReminder(from: normalizedText),
            newRecurrence: extractNewRecurrence(from: normalizedText),
            shouldRemoveRecurrence: shouldRemoveRecurrence(from: normalizedText),
            newNotes: nil
        )
    }

    private func extractNewStartDate(
        from text: String,
        settings: AppSettings
    ) -> Date? {
        guard isMoveCommand(text) else {
            return nil
        }

        return dateParser.extractDate(
            from: text,
            settings: settings
        )
    }

    private func extractNewReminder(from text: String) -> Reminder? {
        guard isReminderCommand(text) else {
            return nil
        }

        if text.contains("за час") ||
            text.contains("на час") {
            return Reminder(minutesBefore: 60)
        }

        if text.contains("за полчаса") ||
            text.contains("на полчаса") {
            return Reminder(minutesBefore: 30)
        }

        if text.contains("за день") ||
            text.contains("на день") {
            return Reminder(minutesBefore: 24 * 60)
        }

        let minutePattern = #"(?i)(?:за|на)\s+(\d{1,3})\s+(?:минут|минуты|минуту)"#

        if let minutes = extractNumber(
            from: text,
            pattern: minutePattern
        ) {
            return Reminder(minutesBefore: minutes)
        }

        let hourPattern = #"(?i)(?:за|на)\s+(\d{1,2})\s+(?:час|часа|часов)"#

        if let hours = extractNumber(
            from: text,
            pattern: hourPattern
        ) {
            return Reminder(minutesBefore: hours * 60)
        }

        return nil
    }

    private func extractNewRecurrence(from text: String) -> RecurrenceRule? {
        guard isRecurrenceCommand(text) else {
            return nil
        }

        return recurrenceParser.extractRecurrence(from: text)
    }

    private func extractNewTitle(from text: String) -> String? {
        guard text.contains("переименуй") ||
              text.contains("переименовать") ||
              text.contains("назови") ||
              text.contains("назвать")
        else {
            return nil
        }

        let separators = [
            " в ",
            " на "
        ]

        for separator in separators {
            if let range = text.range(of: separator) {
                let title = String(text[range.upperBound...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !title.isEmpty {
                    return title.capitalized
                }
            }
        }

        return nil
    }

    private func shouldRemoveReminder(from text: String) -> Bool {
        text.contains("без напоминания") ||
        text.contains("убери напоминание") ||
        text.contains("удали напоминание") ||
        text.contains("отключи напоминание")
    }

    private func shouldRemoveRecurrence(from text: String) -> Bool {
        text.contains("убери повторение") ||
        text.contains("удали повторение") ||
        text.contains("отключи повторение") ||
        text.contains("без повторения")
    }

    private func isMoveCommand(_ text: String) -> Bool {
        text.contains("перенеси") ||
        text.contains("перенести") ||
        text.contains("перемести") ||
        text.contains("переместить")
    }

    private func isReminderCommand(_ text: String) -> Bool {
        text.contains("напоминание") ||
        text.contains("уведомление")
    }

    private func isRecurrenceCommand(_ text: String) -> Bool {
        text.contains("повторение") ||
        text.contains("каждый") ||
        text.contains("каждую") ||
        text.contains("ежедневно") ||
        text.contains("ежемесячно") ||
        text.contains("ежегодно")
    }

    private func extractNumber(
        from text: String,
        pattern: String
    ) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: text,
                range: NSRange(text.startIndex..., in: text)
              ),
              let range = Range(match.range(at: 1), in: text)
        else {
            return nil
        }

        return Int(text[range])
    }
}
