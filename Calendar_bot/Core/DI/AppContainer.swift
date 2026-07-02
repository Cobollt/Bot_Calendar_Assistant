import Foundation

final class AppContainer {

    // MARK: - Services

    lazy var eventKitCalendarService =
        EventKitCalendarService()

    lazy var speechRecognitionService =
        SpeechRecognitionService()

    lazy var settingsService =
        SettingsService()

    lazy var permissionService =
        PermissionService()

    lazy var settingsOpenerService =
        SettingsOpenerService()

    lazy var calendarOpenerService =
        CalendarOpenerService()

    // MARK: - Parsers

    lazy var textNormalizerService =
        TextNormalizerService()

    lazy var timeParserService =
        TimeParserService()

    lazy var dateParserService =
        DateParserService(
            timeParser: timeParserService
        )
    
    lazy var eventKeywordCleaner =
        EventKeywordCleaner()

    lazy var eventDateTextCleaner =
        EventDateTextCleaner()

    lazy var eventTimeTextCleaner =
        EventTimeTextCleaner()

    lazy var eventRecurrenceTextCleaner =
        EventRecurrenceTextCleaner()

    lazy var eventReminderTextCleaner =
        EventReminderTextCleaner()

    lazy var eventTitleBuilderService =
        EventTitleBuilderService(
            keywordCleaner: eventKeywordCleaner,
            dateCleaner: eventDateTextCleaner,
            timeCleaner: eventTimeTextCleaner,
            recurrenceCleaner: eventRecurrenceTextCleaner,
            reminderCleaner: eventReminderTextCleaner
        )
    
    lazy var eventSearchEngine =
        EventSearchEngine()

    lazy var eventKitCalendarService =
        EventKitCalendarService(
            searchEngine: eventSearchEngine
        )

    lazy var titleParserService =
        TitleParserService(
            titleBuilder: eventTitleBuilderService
        )

    lazy var titleParserService =
        TitleParserService()
    
    lazy var commandIntentParserService =
        CommandIntentParserService()

    lazy var recurrenceParserService =
        RecurrenceParserService()

    lazy var commandParserService =
        CommandParserService(
            settingsService: settingsService,
            textNormalizer: textNormalizerService,
            dateParser: dateParserService,
            titleParser: titleParserService,
            recurrenceParser: recurrenceParserService
        )

    // MARK: - Repository

    lazy var calendarRepository =
        ICloudCalendarRepository(
            calendarService: eventKitCalendarService
        )

    // MARK: - UseCases

    lazy var checkPermissionsUseCase =
        CheckPermissionsUseCase(
            permissionService: permissionService
        )

    lazy var requestCalendarAccessUseCase =
        RequestCalendarAccessUseCase(
            permissionService: permissionService
        )

    lazy var getAppSettingsUseCase =
        GetAppSettingsUseCase(
            settingsService: settingsService
        )

    lazy var saveAppSettingsUseCase =
        SaveAppSettingsUseCase(
            settingsService: settingsService
        )

    lazy var startVoiceRecognitionUseCase =
        StartVoiceRecognitionUseCase(
            speechRecognizer: speechRecognitionService
        )

    lazy var parseVoiceCommandUseCase =
        ParseVoiceCommandUseCase(
            commandParser: commandParserService
        )

    lazy var createCalendarEventUseCase =
        CreateCalendarEventUseCase(
            calendarRepository: calendarRepository
        )

    lazy var findCalendarEventsUseCase =
        FindCalendarEventsUseCase(
            calendarRepository: calendarRepository
        )

    lazy var deleteCalendarEventUseCase =
        DeleteCalendarEventUseCase(
            calendarRepository: calendarRepository
        )

    lazy var updateCalendarEventUseCase =
        UpdateCalendarEventUseCase(
            calendarRepository: calendarRepository
        )

    lazy var openSettingsUseCase =
        OpenSettingsUseCase(
            settingsOpener: settingsOpenerService
        )

    lazy var openCalendarUseCase =
        OpenCalendarUseCase(
            calendarOpener: calendarOpenerService
        )

    // MARK: - Flows

    lazy var homeCreateEventFlow =
        HomeCreateEventFlow(
            startVoiceRecognitionUseCase: startVoiceRecognitionUseCase,
            parseVoiceCommandUseCase: parseVoiceCommandUseCase
        )

    lazy var homeDeleteEventFlow =
        HomeDeleteEventFlow(
            startVoiceRecognitionUseCase: startVoiceRecognitionUseCase,
            findCalendarEventsUseCase: findCalendarEventsUseCase
        )

    lazy var homeMoveEventFlow =
        HomeMoveEventFlow(
            startVoiceRecognitionUseCase: startVoiceRecognitionUseCase,
            findCalendarEventsUseCase: findCalendarEventsUseCase,
            parseVoiceCommandUseCase: parseVoiceCommandUseCase
        )

    lazy var homeReminderUpdateFlow =
        HomeReminderUpdateFlow(
            startVoiceRecognitionUseCase: startVoiceRecognitionUseCase,
            findCalendarEventsUseCase: findCalendarEventsUseCase
        )
    
    lazy var voiceCommandFlow =
        VoiceCommandFlow(
            startVoiceRecognitionUseCase: startVoiceRecognitionUseCase,
            textNormalizer: textNormalizerService,
            intentParser: commandIntentParserService,
            createFlow: homeCreateEventFlow,
            deleteFlow: homeDeleteEventFlow,
            moveFlow: homeMoveEventFlow,
            reminderFlow: homeReminderUpdateFlow
        )

    // MARK: - ViewModels

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            checkPermissionsUseCase: checkPermissionsUseCase,
            createCalendarEventUseCase: createCalendarEventUseCase,
            deleteCalendarEventUseCase: deleteCalendarEventUseCase,
            updateCalendarEventUseCase: updateCalendarEventUseCase,
            openCalendarUseCase: openCalendarUseCase,
            voiceCommandFlow: voiceCommandFlow
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            checkPermissionsUseCase: checkPermissionsUseCase,
            requestCalendarAccessUseCase: requestCalendarAccessUseCase,
            getAppSettingsUseCase: getAppSettingsUseCase,
            saveAppSettingsUseCase: saveAppSettingsUseCase,
            openSettingsUseCase: openSettingsUseCase
        )
    }
}
