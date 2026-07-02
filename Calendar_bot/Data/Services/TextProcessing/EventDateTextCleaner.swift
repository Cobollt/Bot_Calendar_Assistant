import Foundation

final class EventDateTextCleaner {

    func clean(_ text: String) -> String {
        var result = text

        let patterns = [
            #"(?i)\bсегодня\b"#,
            #"(?i)\bзавтра\b"#,
            #"(?i)\bпослезавтра\b"#,
            #"(?i)\bчерез\s+\d{1,2}\s+(?:день|дня|дней)\b"#,
            #"(?i)\bчерез\s+\d{1,2}\s+(?:неделю|недели|недель)\b"#,
            #"(?i)\bчерез\s+неделю\b"#,
            #"(?i)\b\d{1,2}[./-]\d{1,2}(?:[./-]\d{2,4})?\b"#,
            #"(?i)\b\d{1,2}\s+(?:января|февраля|марта|апреля|мая|июня|июля|августа|сентября|октября|ноября|декабря)(?:\s+\d{4})?\b"#,
            #"(?i)\b\d{1,2}\s+(?:числа|число)\b"#,
            #"(?i)\b(?:следующую|следующий)?\s*(?:понедельник|вторник|среду|среда|четверг|пятницу|пятница|субботу|суббота|воскресенье)\b"#
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
