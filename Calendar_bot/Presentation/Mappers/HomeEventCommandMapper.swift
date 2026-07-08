import Foundation

enum HomeEventCommandMapper {

    static func makeDeleteSearchText(from text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "отмени", with: "")
            .replacingOccurrences(of: "удали", with: "")
            .replacingOccurrences(of: "удалить", with: "")
            .replacingOccurrences(of: "отменить", with: "")
            .replacingOccurrences(of: "событие", with: "")
            .replacingOccurrences(of: "встречу", with: "")
            .replacingOccurrences(of: "встреча", with: "")
            .replacingOccurrences(
                of: #"\s+"#,
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
