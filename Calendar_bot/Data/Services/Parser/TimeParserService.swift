import Foundation

final class TimeParserService {

    func extractTime(
        from text: String,
        defaultHour: Int
    ) -> (hour: Int, minute: Int) {
        let patterns = [
            #"(?i)(?:в|на)\s+(\d{1,2})[:.](\d{2})"#,
            #"(?i)(?:в|на)\s+(\d{1,2})"#,
            #"(?i)\b(\d{1,2})[:.](\d{2})\b"#
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

        return (defaultHour, 0)
    }
}
