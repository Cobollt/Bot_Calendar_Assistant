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

    private func extractDate(from text: String) throws -> Date {
        let calendar = Calendar.current
        let now = Date()

        if text.contains("завтра") {
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: now)!
            return setTime(for: tomorrow, from: text)
        }

        return setTime(for: now, from: text)
    }

    private func setTime(for date: Date, from text: String) -> Date {
        let calendar = Calendar.current
        let settings = settingsService.getSettings()
        let parsedTime = extractHourAndMinute(from: text)

        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = parsedTime?.hour ?? settings.defaultEventHour
        components.minute = parsedTime?.minute ?? 0

        return calendar.date(from: components) ?? date
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
