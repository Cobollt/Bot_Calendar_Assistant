import Foundation

final class RecurrenceParserService {

    func extractRecurrence(from text: String) -> RecurrenceRule? {

        if text.contains("каждый день") ||
            text.contains("каждое утро") ||
            text.contains("ежедневно") {
            return RecurrenceRule(
                frequency: .daily,
                weekday: nil
            )
        }

        if isWeeklyRecurring(text),
           let weekday = extractWeekday(from: text) {
            return RecurrenceRule(
                frequency: .weekly,
                weekday: weekday
            )
        }

        if text.contains("каждую неделю") ||
            text.contains("еженедельно") {
            return RecurrenceRule(
                frequency: .weekly,
                weekday: nil
            )
        }

        if text.contains("каждый месяц") ||
            text.contains("ежемесячно") {
            return RecurrenceRule(
                frequency: .monthly,
                weekday: nil
            )
        }

        if text.contains("каждый год") ||
            text.contains("ежегодно") {
            return RecurrenceRule(
                frequency: .yearly,
                weekday: nil
            )
        }

        return nil
    }

    private func isWeeklyRecurring(_ text: String) -> Bool {
        text.contains("каждый") ||
        text.contains("каждую") ||
        text.contains("каждое") ||
        text.contains("еженедельно")
    }

    private func extractWeekday(from text: String) -> Int? {
        let weekdays: [String: Int] = [
            "воскресенье": 1,

            "понедельник": 2,
            "понедельникам": 2,

            "вторник": 3,
            "вторникам": 3,

            "среду": 4,
            "среда": 4,
            "средам": 4,

            "четверг": 5,
            "четвергам": 5,

            "пятницу": 6,
            "пятница": 6,
            "пятницам": 6,

            "субботу": 7,
            "суббота": 7,
            "субботам": 7
        ]

        for (word, weekday) in weekdays {
            if text.contains(word) {
                return weekday
            }
        }

        return nil
    }
}
