import Foundation

final class HomeDeleteEventFlow {

    private let startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase
    private let findCalendarEventsUseCase: FindCalendarEventsUseCase

    init(
        startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase,
        findCalendarEventsUseCase: FindCalendarEventsUseCase
    ) {
        self.startVoiceRecognitionUseCase = startVoiceRecognitionUseCase
        self.findCalendarEventsUseCase = findCalendarEventsUseCase
    }

    func prepare() async throws -> (VoiceCommand, HomePendingAction?) {
        let command = try await startVoiceRecognitionUseCase.execute()

        let searchText = HomeEventCommandMapper.makeDeleteSearchText(
            from: command.rawText
        )

        guard let event = try await findFirstEvent(matching: searchText) else {
            return (command, nil)
        }

        return (
            command,
            .delete(
                event,
                EventPresentationMapper.map(event)
            )
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
