import Foundation

final class CommandIntentParserService {

    func parseIntent(from text: String) -> VoiceCommandIntent {
        let normalizedText = normalize(text)

        let scores: [(intent: VoiceCommandIntent, score: Int)] = [
            (.updateReminder, scoreUpdateReminder(normalizedText)),
            (.delete, scoreDelete(normalizedText)),
            (.move, scoreMove(normalizedText)),
            (.create, scoreCreate(normalizedText))
        ]

        let best = scores.max { $0.score < $1.score }

        guard let best, best.score > 0 else {
            return .unknown
        }

        return best.intent
    }

    private func scoreCreate(_ text: String) -> Int {
        score(
            text,
            keywords: [
                "создай",
                "создать",
                "добавь",
                "добавить",
                "запиши",
                "записать",
                "напомни",
                "напомнить"
            ]
        )
    }

    private func scoreDelete(_ text: String) -> Int {
        score(
            text,
            keywords: [
                "удали",
                "удалить",
                "отмени",
                "отменить",
                "убери",
                "убрать"
            ]
        )
    }

    private func scoreMove(_ text: String) -> Int {
        score(
            text,
            keywords: [
                "перенеси",
                "перенести",
                "перемести",
                "переместить",
                "сдвинь",
                "сдвинуть"
            ]
        )
    }

    private func scoreUpdateReminder(_ text: String) -> Int {
        var result = score(
            text,
            keywords: [
                "измени напоминание",
                "изменить напоминание",
                "поменяй напоминание",
                "поменять напоминание",
                "измени уведомление",
                "изменить уведомление",
                "поменяй уведомление",
                "поменять уведомление"
            ]
        )

        if text.contains("напоминание") || text.contains("уведомление") {
            result += 1
        }

        if text.contains("за час") ||
            text.contains("за полчаса") ||
            text.contains("за день") ||
            text.contains("без напоминания") {
            result += 1
        }

        return result
    }

    private func score(
        _ text: String,
        keywords: [String]
    ) -> Int {
        keywords.reduce(0) { total, keyword in
            text.contains(keyword) ? total + 2 : total
        }
    }

    private func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(
                of: #"\s+"#,
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
