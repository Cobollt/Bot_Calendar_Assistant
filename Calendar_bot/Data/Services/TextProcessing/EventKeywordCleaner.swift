import Foundation

final class EventKeywordCleaner {

    func clean(_ text: String) -> String {
        var result = text

        let patterns = [
            #"(?i)\bсоздай\b"#,
            #"(?i)\bсоздать\b"#,
            #"(?i)\bдобавь\b"#,
            #"(?i)\bдобавить\b"#,
            #"(?i)\bзапиши\b"#,
            #"(?i)\bзаписать\b"#,
            #"(?i)\bнапомни\b"#,
            #"(?i)\bнапомнить\b"#,
            #"(?i)\bудали\b"#,
            #"(?i)\bудалить\b"#,
            #"(?i)\bотмени\b"#,
            #"(?i)\bотменить\b"#,
            #"(?i)\bперенеси\b"#,
            #"(?i)\bперенести\b"#,
            #"(?i)\bизмени\b"#,
            #"(?i)\bпоменяй\b"#,
            #"(?i)\bмне\b"#
        ]

        for pattern in patterns {
            result = result.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }

        return normalizeSpaces(result)
    }

    private func normalizeSpaces(_ text: String) -> String {
        text.replacingOccurrences(
            of: #"\s+"#,
            with: " ",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
