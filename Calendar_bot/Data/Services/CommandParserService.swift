import Foundation

final class CommandParserService: CommandParserProtocol {
    
    private let settingsService: SettingsServiceProtocol

    init(settingsService: SettingsServiceProtocol) {
        self.settingsService = settingsService
    }

    func parse(_ command: VoiceCommand) throws -> CalendarEvent {
        let text = command.rawText.lowercased()
        
        guard !text.isEmpty else {
                throw ParserError.emptyCommand
            }
        
        let settings = settingsService.getSettings()
        let startDate = try extractDate(from: text)
        let endDate = startDate.addingTimeInterval(
            TimeInterval(settings.defaultEventDurationMinutes * 60)
        )

        let title = extractTitle(from: text)
        
        guard !title.isEmpty else {
                throw ParserError.emptyTitle
            }

        return CalendarEvent(
            id: UUID(),
            title: title,
            startDate: startDate,
            endDate: endDate,
            notes: command.rawText,
            reminder: Reminder(minutesBefore: settings.defaultReminderMinutes)
        )
    }
    
    private func extractDate(
        from text: String,
        settings: AppSettings
    ) throws -> Date {

        if let date = extractNumericDate(from: text, settings: settings) {
            return date
        }

        if let date = extractWrittenDate(from: text, settings: settings) {
            return date
        }

        if let date = extractRelativeDate(from: text, settings: settings) {
            return date
        }

        if let date = extractWeekdayDate(from: text, settings: settings) {
            return date
        }

        throw ParserError.invalidDate
    }

    private func setTime(
        for date: Date,
        from text: String,
        settings: AppSettings
    ) -> Date {
        let calendar = Calendar.current
        let parsedTime = extractHourAndMinute(from: text)

        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = parsedTime?.hour ?? settings.defaultEventHour
        components.minute = parsedTime?.minute ?? 0

        return calendar.date(from: components) ?? date
    }
    
    private func extractRelativeDate(
        from text: String,
        settings: AppSettings
    ) -> Date? {
        let calendar = Calendar.current
        let now = Date()

        if text.contains("сегодня") {
            return setTime(for: now, from: text, settings: settings)
        }

        if text.contains("завтра") {
            let date = calendar.date(byAdding: .day, value: 1, to: now)
            return date.map { setTime(for: $0, from: text, settings: settings) }
        }

        if text.contains("послезавтра") {
            let date = calendar.date(byAdding: .day, value: 2, to: now)
            return date.map { setTime(for: $0, from: text, settings: settings) }
        }

        if text.contains("через неделю") {
            let date = calendar.date(byAdding: .day, value: 7, to: now)
            return date.map { setTime(for: $0, from: text, settings: settings) }
        }

        let dayPattern = #"через\s+(\d{1,2})\s+(?:день|дня|дней)"#

        if let days = extractNumber(from: text, pattern: dayPattern) {
            let date = calendar.date(byAdding: .day, value: days, to: now)
            return date.map { setTime(for: $0, from: text, settings: settings) }
        }

        let weekPattern = #"через\s+(\d{1,2})\s+(?:неделю|недели|недель)"#

        if let weeks = extractNumber(from: text, pattern: weekPattern) {
            let date = calendar.date(byAdding: .day, value: weeks * 7, to: now)
            return date.map { setTime(for: $0, from: text, settings: settings) }
        }

        return nil
    }
    
    private func extractNumericDate(
        from text: String,
        settings: AppSettings
    ) -> Date? {
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

        guard let date = calendar.date(from: components) else {
            return nil
        }

        return setTime(for: date, from: text, settings: settings)
    }
    
    private func extractWrittenDate(
        from text: String,
        settings: AppSettings
    ) -> Date? {
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

        guard let date = calendar.date(from: components) else {
            return nil
        }

        return setTime(for: date, from: text, settings: settings)
    }
    
    private func extractWeekdayDate(
        from text: String,
        settings: AppSettings
    ) -> Date? {
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
                    from: text,
                    settings: settings,
                    forceNextWeek: text.contains("следующ")
                )
            }
        }

        return nil
    }

    private func nextWeekday(
        _ targetWeekday: Int,
        from text: String,
        settings: AppSettings,
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

        guard let date = calendar.date(byAdding: .day, value: daysToAdd, to: now) else {
            return nil
        }

        return setTime(for: date, from: text, settings: settings)
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

    private func extractHourAndMinute(from text: String) -> (hour: Int, minute: Int)? {
        let patterns = [
            #"(?i)(?:в|на)\s+(\d{1,2})[:.](\d{2})"#,
            #"(?i)(?:в|на)\s+(\d{1,2})"#,
            #"(?i)завтра\s+(\d{1,2})[:.](\d{2})"#,
            #"(?i)завтра\s+(\d{1,2})"#
        ]

        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(
                    in: text,
                    range: NSRange(text.startIndex..., in: text)
                  ),
                  let hourRange = Range(match.range(at: 1), in: text),
                  let hour = Int(text[hourRange]),
                  hour >= 0,
                  hour <= 23
            else {
                continue
            }

            var minute = 0

            if match.numberOfRanges > 2,
               let minuteRange = Range(match.range(at: 2), in: text),
               let parsedMinute = Int(text[minuteRange]),
               parsedMinute >= 0,
               parsedMinute <= 59 {
                minute = parsedMinute
            }

            return (hour, minute)
        }

        return nil
    }
    
    private func extractTitle(from text: String) -> String {
        text
            .replacingOccurrences(of: "напомни", with: "")
            .replacingOccurrences(of: "добавь", with: "")
            .replacingOccurrences(of: "создай", with: "")
            .replacingOccurrences(of: "завтра", with: "")
            .replacingOccurrences(of: "сегодня", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
    }
}
