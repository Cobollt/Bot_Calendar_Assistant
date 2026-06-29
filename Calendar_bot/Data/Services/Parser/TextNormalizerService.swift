import Foundation

final class TextNormalizerService {

    func normalize(_ text: String) -> String {
        var result = text
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        result = replaceMultipleSpaces(in: result)
        result = normalizeTimeWords(in: result)
        result = normalizeWeekdayWords(in: result)
        result = normalizeNumberWords(in: result)
        result = replaceMultipleSpaces(in: result)

        return result
    }

    private func replaceMultipleSpaces(in text: String) -> String {
        text.replacingOccurrences(
            of: #"\s+"#,
            with: " ",
            options: .regularExpression
        )
    }

    private func normalizeTimeWords(in text: String) -> String {
        var result = text

        let replacements: [String: String] = [
            " часов": "",
            " часа": "",
            " час": "",
            " точка ": ":",
            " двоеточие ": ":",
            " ноль ноль": ":00"
        ]

        for (source, target) in replacements {
            result = result.replacingOccurrences(of: source, with: target)
        }

        return result
    }

    private func normalizeWeekdayWords(in text: String) -> String {
        var result = text

        let replacements: [String: String] = [
            "во вторник": "в вторник",
            "в среду": "среда",
            "в пятницу": "пятница",
            "в субботу": "суббота",
            "в воскресенье": "воскресенье"
        ]

        for (source, target) in replacements {
            result = result.replacingOccurrences(of: source, with: target)
        }

        return result
    }

    private func normalizeNumberWords(in text: String) -> String {
        var result = text

        let replacements: [String: String] = [
            " в один": " в 1",
            " в два": " в 2",
            " в три": " в 3",
            " в четыре": " в 4",
            " в пять": " в 5",
            " в шесть": " в 6",
            " в семь": " в 7",
            " в восемь": " в 8",
            " в девять": " в 9",
            " в десять": " в 10",
            " в одиннадцать": " в 11",
            " в двенадцать": " в 12",
            " в тринадцать": " в 13",
            " в четырнадцать": " в 14",
            " в пятнадцать": " в 15",
            " в шестнадцать": " в 16",
            " в семнадцать": " в 17",
            " в восемнадцать": " в 18",
            " в девятнадцать": " в 19",
            " в двадцать": " в 20",
            " в двадцать один": " в 21",
            " в двадцать два": " в 22",
            " в двадцать три": " в 23"
        ]

        for (source, target) in replacements {
            result = result.replacingOccurrences(of: source, with: target)
        }

        return result
    }
}
