import Foundation

final class EventRecurrenceTextCleaner {

    func clean(_ text: String) -> String {
        var result = text

        let patterns = [
            #"(?i)\bкаждый день\b"#,
            #"(?i)\bкаждое утро\b"#,
            #"(?i)\bежедневно\b"#,
            #"(?i)\bкаждую неделю\b"#,
            #"(?i)\bеженедельно\b"#,
            #"(?i)\bкаждый месяц\b"#,
            #"(?i)\bежемесячно\b"#,
            #"(?i)\bкаждый год\b"#,
            #"(?i)\bежегодно\b"#,
            #"(?i)\bкаждый\s+(?:понедельник|вторник|четверг)\b"#,
            #"(?i)\bкаждую\s+(?:среду|пятницу|субботу)\b"#,
            #"(?i)\bкаждое\s+воскресенье\b"#
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
