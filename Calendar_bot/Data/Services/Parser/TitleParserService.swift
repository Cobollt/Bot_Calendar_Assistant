import Foundation

final class TitleParserService {

    func extractTitle(from text: String) -> String {
        var result = text

        let patterns = [
            #"(?i)\bнапомни\b"#,
            #"(?i)\bдобавь\b"#,
            #"(?i)\bсоздай\b"#,
            #"(?i)\bзапиши\b"#,
            #"(?i)\bмне\b"#,

            #"(?i)\bсегодня\b"#,
            #"(?i)\bзавтра\b"#,
            #"(?i)\bпослезавтра\b"#,

            #"(?i)через\s+\d{1,2}\s+(?:день|дня|дней)"#,
            #"(?i)через\s+\d{1,2}\s+(?:неделю|недели|недель)"#,
            #"(?i)через\s+неделю"#,

            #"(?i)\d{1,2}[./-]\d{1,2}(?:[./-]\d{2,4})?"#,
            #"(?i)\d{1,2}\s+(?:января|февраля|марта|апреля|мая|июня|июля|августа|сентября|октября|ноября|декабря)(?:\s+\d{4})?"#,

            #"(?i)\bв\s+(?:следующую|следующий)?\s*(?:понедельник|вторник|среду|среда|четверг|пятницу|пятница|субботу|суббота|воскресенье)\b"#,

            #"(?i)(?:в|на)\s+\d{1,2}[:.]\d{2}"#,
            #"(?i)(?:в|на)\s+\d{1,2}"#
        ]

        for pattern in patterns {
            result = result.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        result = result
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return capitalizeFirstLetter(result)
    }

    private func capitalizeFirstLetter(_ text: String) -> String {
        guard let first = text.first else {
            return text
        }

        return first.uppercased() + text.dropFirst()
    }
}
