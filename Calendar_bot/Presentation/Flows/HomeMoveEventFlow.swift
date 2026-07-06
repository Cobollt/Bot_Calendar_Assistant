import Foundation

final class HomeMoveEventFlow {

    private let findCalendarEventsUseCase: FindCalendarEventsUseCase
    private let parseVoiceCommandUseCase: ParseVoiceCommandUseCase

    init(
        findCalendarEventsUseCase: FindCalendarEventsUseCase,
        parseVoiceCommandUseCase: ParseVoiceCommandUseCase
    ) {
        self.findCalendarEventsUseCase = findCalendarEventsUseCase
        self.parseVoiceCommandUseCase = parseVoiceCommandUseCase
    }

    func prepare(from command: VoiceCommand) async throws -> HomePendingAction? {
        let searchText = HomeEventCommandMapper.makeMoveSearchText(
            from: command.rawText
        )

        guard let event = try await findFirstEvent(matching: searchText) else {
            return nil
        }

        let movedEvent = try HomeEventCommandMapper.makeMovedEvent(
            originalEvent: event,
            commandText: command.rawText,
            parseVoiceCommandUseCase: parseVoiceCommandUseCase
        )

        return .move(
            movedEvent,
            EventPresentationMapper.map(movedEvent)
        )
    }

    private func findFirstEvent(
        matching text: String?
    ) async throws -> CalendarEvent? {
        let calendar = Calendar.current
        let now = Date()
        let endDate = calendar.date(
            byAdding: .day,
            value: 60,
            to: now
        ) ?? now

        let events = try await findCalendarEventsUseCase.execute(
            matching: text,
            from: now,
            to: endDate
        )

        return events.first
    }
}
