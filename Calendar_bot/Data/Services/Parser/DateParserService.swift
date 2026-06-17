import Foundation

final class DateParserService {

    private let timeParser: TimeParserService

    init(timeParser: TimeParserService) {
        self.timeParser = timeParser
    }

    func extractDate(
        from text: String,
        settings: AppSettings
    ) -> Date {
        let baseDate =
            extractNumericDate(from: text)
            ?? extractWrittenDate(from: text)
            ?? extractRelativeDate(from: text)
            ?? extractWeekdayDate(from: text)
            ?? Date()

        return setTime(
            for: baseDate,
            from: text,
            settings: settings
        )
    }

    private func setTime(
        for date: Date,
        from text: String,
        settings: AppSettings
    ) -> Date {
        let calendar = Calendar.current

        let parsedTime = timeParser.extractTime(
            from: text,
            defaultHour: settings.defaultEventHour
        )

        var components = calendar.dateComponents(
            [.year, .month, .day],
            from: date
        )

        components.hour = parsedTime.hour
        components.minute = parsedTime.minute

        return calendar.date(from: components) ?? date
    }

    private func extractRelativeDate(from text: String) -> Date? {
        let calendar = Calendar.current
        let now = Date()

        if text.contains("послезавтра") {
            return calendar.date(byAdding: .day, value: 2, to: now)
        }

        if text.contains("завтра") {
            return calendar.date(byAdding: .day, value: 1, to: now)
        }

        if text.contains("сегодня") {
            return now
        }

        if text.contains("через неделю") {
            return calendar.date(byAdding: .day, value: 7, to: now)
        }

        let dayPattern = #"через\s+(\d{1,2})\s+(?:день|дня|дней)"#

        if let days = extractNumber(from: text, pattern: dayPattern) {
            return calendar.date(byAdding: .day, value: days, to: now)
        }

        let weekPattern = #"через\s+(\d{1,2})\s+(?:неделю|недели|недель)"#

        if let weeks = extractNumber(from: text, pattern: weekPattern) {
            return calendar.date(byAdding: .day, value: weeks * 7, to: now)
        }

        return nil
    }

    private func extractNumericDate(from text: String) -> Date? {
        let pattern = #"(\d{1,2})[./-](\d{1,2})(?:[./-](\d{2,4}))?"#

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: text,
                range: NSRange(text.startIndex..., in: text)
              ),
              let dayRange = Range(match.range(at: 1), in: text),
              let monthRange = Range(match.range(at: 2), in: text),
              let day = Int(text[dayRange]),
              let month = Int(text[monthRange])
        else {
            return nil
        }

        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())

        var year = currentYear

        if match.range(at: 3).location != NSNotFound,
           let yearRange = Range(match.range(at: 3), in: text),
           let parsedYear = Int(text[yearRange]) {
            year = parsedYear < 100 ? 2000 + parsedYear : parsedYear
        }

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day

        return calendar.date(from: components)
    }

    private func extractWrittenDate(from text: String) -> Date? {
        let months: [String: Int] = [
            "января": 1,
            "февраля": 2,
            "марта": 3,
            "апреля": 4,
            "мая": 5,
            "июня": 6,
            "июля": 7,
            "августа": 8,
            "сентября": 9,
            "октября": 10,
            "ноября": 11,
            "декабря": 12
        ]

        let pattern = #"(\d{1,2})\s+(января|февраля|марта|апреля|мая|июня|июля|августа|сентября|октября|ноября|декабря)(?:\s+(\d{4}))?"#

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: text,
                range: NSRange(text.startIndex..., in: text)
              ),
              let dayRange = Range(match.range(at: 1), in: text),
              let monthRange = Range(match.range(at: 2), in: text),
              let day = Int(text[dayRange])
        else {
            return nil
        }

        let monthName = String(text[monthRange])

        guard let month = months[monthName] else {
            return nil
        }

        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())

        var year = currentYear

        if match.range(at: 3).location != NSNotFound,
           let yearRange = Range(match.range(at: 3), in: text),
           let parsedYear = Int(text[yearRange]) {
            year = parsedYear
        }

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day

        return calendar.date(from: components)
    }

    private func extractWeekdayDate(from text: String) -> Date? {
        let weekdays: [String: Int] = [
            "воскресенье": 1,
            "понедельник": 2,
            "вторник": 3,
            "среду": 4,
            "среда": 4,
            "четверг": 5,
            "пятницу": 6,
            "пятница": 6,
            "субботу": 7,
            "суббота": 7
        ]

        for (word, weekday) in weekdays {
            if text.contains(word) {
                return nextWeekday(
                    weekday,
                    forceNextWeek: text.contains("следующ")
                )
            }
        }

        return nil
    }

    private func nextWeekday(
        _ targetWeekday: Int,
        forceNextWeek: Bool
    ) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        let currentWeekday = calendar.component(.weekday, from: now)

        var daysToAdd = targetWeekday - currentWeekday

        if daysToAdd <= 0 {
            daysToAdd += 7
        }

        if forceNextWeek {
            daysToAdd += 7
        }

        return calendar.date(byAdding: .day, value: daysToAdd, to: now)
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
