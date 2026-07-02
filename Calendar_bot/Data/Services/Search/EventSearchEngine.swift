import Foundation

final class EventSearchEngine {

    func findBestMatch(
        events: [CalendarEvent],
        query: String?
    ) -> CalendarEvent? {
        guard let query,
              !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return events.sorted { $0.startDate < $1.startDate }.first
        }

        let normalizedQuery = normalize(query)

        let scoredEvents = events.map { event in
            (
                event: event,
                score: calculateScore(
                    event: event,
                    query: normalizedQuery
                )
            )
        }

        return scoredEvents
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            .first?
            .event
    }

    func filterAndSort(
        events: [CalendarEvent],
        query: String?
    ) -> [CalendarEvent] {
        guard let query,
              !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return events.sorted { $0.startDate < $1.startDate }
        }

        let normalizedQuery = normalize(query)

        return events
            .map { event in
                (
                    event: event,
                    score: calculateScore(
                        event: event,
                        query: normalizedQuery
                    )
                )
            }
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            .map { $0.event }
    }

    private func calculateScore(
        event: CalendarEvent,
        query: String
    ) -> Int {
        let title = normalize(event.title)
        let notes = normalize(event.notes ?? "")

        let queryWords = query
            .split(separator: " ")
            .map(String.init)
            .filter { $0.count > 1 }

        var score = 0

        if title == query {
            score += 100
        }

        if title.contains(query) {
            score += 60
        }

        for word in queryWords {
            if title.contains(word) {
                score += 20
            }

            if notes.contains(word) {
                score += 5
            }
        }

        return score
    }

    private func normalize(_ text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(
                of: #"[^\p{L}\p{N}\s]"#,
                with: "",
                options: .regularExpression
            )
            .replacingOccurrences(
                of: #"\s+"#,
                with: " ",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
