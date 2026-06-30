import Foundation

enum HomeEventCommandMapper {

    static func makeDeleteSearchText(from text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "отмени", with: "")
            .replacingOccurrences(of: "удали", with: "")
            .replacingOccurrences(of: "событие", with: "")
            .replacingOccurrences(of: "встречу", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func makeMoveSearchText(from text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "перенеси", with: "")
            .replacingOccurrences(of: "перенести", with: "")
            .replacingOccurrences(of: "событие", with: "")
            .replacingOccurrences(of: "встречу", with: "")
            .replacingOccurrences(of: "на час позже", with: "")
            .replacingOccurrences(of: "на час раньше", with: "")
            .replacingOccurrences(of: "на 30 минут позже", with: "")
            .replacingOccurrences(of: "на 30 минут раньше", with: "")
            .replacingOccurrences(of: "на следующий понедельник", with: "")
            .replacingOccurrences(of: "на следующую пятницу", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func makeReminderSearchText(from text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "измени", with: "")
            .replacingOccurrences(of: "поменяй", with: "")
            .replacingOccurrences(of: "напоминание", with: "")
            .replacingOccurrences(of: "на час", with: "")
            .replacingOccurrences(of: "за час", with: "")
            .replacingOccurrences(of: "на полчаса", with: "")
            .replacingOccurrences(of: "за полчаса", with: "")
            .replacingOccurrences(of: "без напоминания", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func extractReminderMinutes(from text: String) -> Int? {
        let lowercasedText = text.lowercased()

        if lowercasedText.contains("без напоминания") {
            return 0
        }

        if lowercasedText.contains("за час") ||
            lowercasedText.contains("на час") {
            return 60
        }

        if lowercasedText.contains("за полчаса") ||
            lowercasedText.contains("на полчаса") {
            return 30
        }

        if lowercasedText.contains("за день") ||
            lowercasedText.contains("на день") {
            return 24 * 60
        }

        let minutePattern = #"(?i)(?:за|на)\s+(\d{1,3})\s+(?:минут|минуты|минуту)"#

        if let minutes = extractNumber(from: lowercasedText, pattern: minutePattern) {
            return minutes
        }

        let hourPattern = #"(?i)(?:за|на)\s+(\d{1,2})\s+(?:час|часа|часов)"#

        if let hours = extractNumber(from: lowercasedText, pattern: hourPattern) {
            return hours * 60
        }

        return nil
    }

    static func makeMovedEvent(
        originalEvent: CalendarEvent,
        commandText: String,
        parseVoiceCommandUseCase: ParseVoiceCommandUseCase
    ) throws -> CalendarEvent {
        let lowercasedText = commandText.lowercased()

        let duration = originalEvent.endDate.timeIntervalSince(
            originalEvent.startDate
        )

        let newStartDate: Date

        if lowercasedText.contains("на час позже") {
            newStartDate = originalEvent.startDate.addingTimeInterval(60 * 60)
        } else if lowercasedText.contains("на час раньше") {
            newStartDate = originalEvent.startDate.addingTimeInterval(-60 * 60)
        } else if lowercasedText.contains("на 30 минут позже") {
            newStartDate = originalEvent.startDate.addingTimeInterval(30 * 60)
        } else if lowercasedText.contains("на 30 минут раньше") {
            newStartDate = originalEvent.startDate.addingTimeInterval(-30 * 60)
        } else {
            let voiceCommand = VoiceCommand(
                rawText: commandText,
                createdAt: Date()
            )

            let parsedEvent = try parseVoiceCommandUseCase.execute(voiceCommand)
            newStartDate = parsedEvent.startDate
        }

        let newEndDate = newStartDate.addingTimeInterval(duration)

        return CalendarEvent(
            id: originalEvent.id,
            externalIdentifier: originalEvent.externalIdentifier,
            title: originalEvent.title,
            startDate: newStartDate,
            endDate: newEndDate,
            notes: originalEvent.notes,
            reminder: originalEvent.reminder,
            recurrenceRule: originalEvent.recurrenceRule
        )
    }

    private static func extractNumber(
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
