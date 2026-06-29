import Foundation

enum RecurrenceFrequency {
    case daily
    case weekly
    case monthly
    case yearly
}

struct RecurrenceRule {
    let frequency: RecurrenceFrequency
    let weekday: Int?
}
