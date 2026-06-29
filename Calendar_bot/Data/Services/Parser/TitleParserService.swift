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
            #"(?i)\bкаждое\s+воскресенье\b"#,

            #"(?i)\bсегодня\b"#,
            #"(?i)\bзавтра\b"#,
            #"(?i)\bпослезавтра\b"#,

            #"(?i)через\s+\d{1,2}\s+(?:день|дня|дней)"#,
            #"(?i)через\s+\d{1,2}\s+(?:неделю|недели|недель)"#,
            #"(?i)через\s+неделю"#,

            #"(?i)\d{1,2}[./-]\d{1,2}(?:[./-]\d{2,4})?"#,
            #"(?i)\d{1,2}\s+(?:января|февраля|марта|апреля|мая|июня|июля|августа|сентября|октября|ноября|декабря)(?:\s+\d{4})?"#,
            #"(?i)\d{1,2}\s+(?:числа|число)"#,

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

        result = result.replacingOccurrences(
            of: #"\s+"#,
            with: " ",
            options: .regularExpression
        )

        result = result.trimmingCharacters(in: .whitespacesAndNewlines)

        return capitalizeFirstLetter(result)
    }

    private func capitalizeFirstLetter(_ text: String) -> String {
        guard let first = text.first else {
            return text
        }

        return first.uppercased() + text.dropFirst()
    }
}
