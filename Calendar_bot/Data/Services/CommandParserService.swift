import Foundation

final class CommandParserService: CommandParserProtocol {

    private let settingsService: SettingsServiceProtocol
    private let textNormalizer: TextNormalizerService
    private let dateParser: DateParserService
    private let titleParser: TitleParserService
    private let recurrenceParser: RecurrenceParserService

    init(
        settingsService: SettingsServiceProtocol,
        textNormalizer: TextNormalizerService,
        dateParser: DateParserService,
        titleParser: TitleParserService,
        recurrenceParser: RecurrenceParserService
    ) {
        self.settingsService = settingsService
        self.textNormalizer = textNormalizer
        self.dateParser = dateParser
        self.titleParser = titleParser
        self.recurrenceParser = recurrenceParser
    }

    func parse(_ command: VoiceCommand) throws -> CalendarEvent {
        let text = textNormalizer.normalize(command.rawText)

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

        let recurrenceRule = recurrenceParser.extractRecurrence(from: text)

        return CalendarEvent(
            id: UUID(),
            externalIdentifier: nil,
            title: title,
            startDate: startDate,
            endDate: endDate,
            notes: command.rawText,
            reminder: Reminder(
                minutesBefore: settings.defaultReminderMinutes
            ),
            recurrenceRule: recurrenceRule
        )
    }
}
