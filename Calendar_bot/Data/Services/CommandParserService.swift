import Foundation

final class CommandParserService: CommandParserProtocol {

    private let settingsService: SettingsServiceProtocol
    private let dateParser: DateParserService
    private let titleParser: TitleParserService

    init(
        settingsService: SettingsServiceProtocol,
        dateParser: DateParserService,
        titleParser: TitleParserService
    ) {
        self.settingsService = settingsService
        self.dateParser = dateParser
        self.titleParser = titleParser
    }

    func parse(_ command: VoiceCommand) throws -> CalendarEvent {
        let text = command.rawText
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            throw ParserError.emptyCommand
        }

        let settings = settingsService.getSettings()

        let startDate = dateParser.extractDate(
            from: text,
            settings: settings
        )

        let endDate = startDate.addingTimeInterval(
            TimeInterval(settings.defaultEventDurationMinutes * 60)
        )

        let title = titleParser.extractTitle(from: text)

        guard !title.isEmpty else {
            throw ParserError.emptyTitle
        }

        return CalendarEvent(
            id: UUID(),
            title: title,
            startDate: startDate,
            endDate: endDate,
            notes: command.rawText,
            reminder: Reminder(
                minutesBefore: settings.defaultReminderMinutes
            )
        )
    }
}
