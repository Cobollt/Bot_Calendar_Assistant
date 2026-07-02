import Foundation

final class EventTitleBuilderService {

    private let keywordCleaner: EventKeywordCleaner
    private let dateCleaner: EventDateTextCleaner
    private let timeCleaner: EventTimeTextCleaner
    private let recurrenceCleaner: EventRecurrenceTextCleaner
    private let reminderCleaner: EventReminderTextCleaner

    init(
        keywordCleaner: EventKeywordCleaner,
        dateCleaner: EventDateTextCleaner,
        timeCleaner: EventTimeTextCleaner,
        recurrenceCleaner: EventRecurrenceTextCleaner,
        reminderCleaner: EventReminderTextCleaner
    ) {
        self.keywordCleaner = keywordCleaner
        self.dateCleaner = dateCleaner
        self.timeCleaner = timeCleaner
        self.recurrenceCleaner = recurrenceCleaner
        self.reminderCleaner = reminderCleaner
    }

    func buildTitle(from text: String) -> String {
        let originalText = text.lowercased()

        var result = originalText

        result = keywordCleaner.clean(result)
        result = recurrenceCleaner.clean(result)
        result = reminderCleaner.clean(result)
        result = dateCleaner.clean(result)
        result = timeCleaner.clean(result)

        result = cleanExtraWords(result)
        result = restoreEventTypeIfNeeded(
            cleanedText: result,
            originalText: originalText
        )

        result = normalizeSpaces(result)

        if result.isEmpty {
            return "Событие"
        }

        return capitalizeFirstLetter(result)
    }

    private func restoreEventTypeIfNeeded(
        cleanedText: String,
        originalText: String
    ) -> String {
        var result = cleanedText

        if originalText.contains("встреч") {
            result = result
                .replacingOccurrences(of: "встречу", with: "встреча")
                .replacingOccurrences(of: "встречи", with: "встреча")

            if !result.contains("встреч") {
                result = "встреча " + result
            }
        }

        if originalText.contains("событ") {
            result = result
                .replacingOccurrences(of: "событие", with: "событие")
                .replacingOccurrences(of: "события", with: "событие")

            if !result.contains("событ") {
                result = "событие " + result
            }
        }

        if originalText.contains("позвон") || originalText.contains("звон") {
            if result.contains("маме") ||
                result.contains("папе") ||
                result.contains("ивану") ||
                result.contains("анне") ||
                result.contains("клиент") {
                result = "позвонить " + result
            } else if !result.contains("позвон") && !result.contains("звон") {
                result = "звонок " + result
            }
        }

        return result
    }

    private func cleanExtraWords(_ text: String) -> String {
        var result = text

        let patterns = [
            #"(?i)\bна\b"#,
            #"(?i)\bв\b"#,
            #"(?i)\bк\b"#,
            #"(?i)\bо\b"#,
            #"(?i)\bоб\b"#
        ]

        for pattern in patterns {
            result = result.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        return result
    }

    private func normalizeSpaces(_ text: String) -> String {
        text.replacingOccurrences(
            of: #"\s+"#,
            with: " ",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func capitalizeFirstLetter(_ text: String) -> String {
        guard let first = text.first else {
            return text
        }

        return first.uppercased() + text.dropFirst()
    }
}
