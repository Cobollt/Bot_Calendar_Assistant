import Foundation

final class CommandIntentParserService {

    func parseIntent(from text: String) -> VoiceCommandIntent {
        let normalizedText = normalize(text)

        let scores: [(intent: VoiceCommandIntent, score: Int)] = [
            (.delete, scoreDelete(normalizedText)),
            (.edit, scoreEdit(normalizedText)),
            (.create, scoreCreate(normalizedText))
        ]

        guard let best = scores.max(by: { $0.score < $1.score }),
              best.score > 0
        else {
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
                "убери событие",
                "убрать событие",
                "удали встречу",
                "отмени встречу"
            ]
        )
    }

    private func scoreEdit(_ text: String) -> Int {
        var result = score(
            text,
            keywords: [
                "перенеси",
                "перенести",
                "перемести",
                "переместить",
                "сдвинь",
                "сдвинуть",
                "измени",
                "изменить",
                "поменяй",
                "поменять",
                "переименуй",
                "переименовать",
                "назови",
                "назвать",
                "напоминание",
                "уведомление",
                "повторение"
            ]
        )

        if text.contains("на час позже") ||
            text.contains("на час раньше") ||
            text.contains("на 30 минут позже") ||
            text.contains("на 30 минут раньше") {
            result += 2
        }

        if text.contains("без напоминания") ||
            text.contains("за час") ||
            text.contains("за полчаса") ||
            text.contains("за день") {
            result += 2
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
