import Foundation

final class EventTimeTextCleaner {

    func clean(_ text: String) -> String {
        var result = text

        let patterns = [
            #"(?i)\b(?:в|на)\s+\d{1,2}[:.]\d{2}\b"#,
            #"(?i)\b(?:в|на)\s+\d{1,2}\b"#,
            #"(?i)\b\d{1,2}[:.]\d{2}\b"#
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
