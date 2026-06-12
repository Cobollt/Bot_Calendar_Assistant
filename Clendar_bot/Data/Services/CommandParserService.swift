import Foundation

final class CommandParserService: CommandParserProtocol {

    func parse(_ command: VoiceCommand) throws -> CalendarEvent {
        let text = command.rawText.lowercased()

        let startDate = try extractDate(from: text)
        let endDate = startDate.addingTimeInterval(AppConstants.defaultReminderMinutes * AppConstants.defaultEventDurationMinutes)

        let title = extractTitle(from: text)

        return CalendarEvent(
            title: title,
            startDate: startDate,
            endDate: endDate,
            notes: command.rawText,
            reminder: Reminder(minutesBefore: AppConstants.defaultReminderMinutes)
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

        let hour = AppConstants.defaultEventHour

        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = 0

        return calendar.date(from: components) ?? date
    }

    private func extractHour(from text: String) -> Int? {
        let pattern = #"в\s?(\d{1,2})"#

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
