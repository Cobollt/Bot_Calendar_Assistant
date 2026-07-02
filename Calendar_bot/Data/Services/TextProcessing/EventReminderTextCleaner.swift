import Foundation

final class EventReminderTextCleaner {

    func clean(_ text: String) -> String {
        var result = text

        let patterns = [
            #"(?i)\bнапоминание\b"#,
            #"(?i)\bуведомление\b"#,
            #"(?i)\bза\s+\d{1,3}\s+(?:минут|минуты|минуту)\b"#,
            #"(?i)\bна\s+\d{1,3}\s+(?:минут|минуты|минуту)\b"#,
            #"(?i)\bза\s+\d{1,2}\s+(?:час|часа|часов)\b"#,
            #"(?i)\bна\s+\d{1,2}\s+(?:час|часа|часов)\b"#,
            #"(?i)\bза час\b"#,
            #"(?i)\bна час\b"#,
            #"(?i)\bза полчаса\b"#,
            #"(?i)\bна полчаса\b"#,
            #"(?i)\bбез напоминания\b"#
        ]

        for pattern in patterns {
            result = result.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        return normalizeSpaces(result)
    }

    private func normalizeSpaces(_ text: String) -> String {
        text.replacingOccurrences(
            of: #"\s+"#,
            with: " ",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
