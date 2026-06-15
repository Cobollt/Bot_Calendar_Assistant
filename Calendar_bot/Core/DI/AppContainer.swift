import Foundation

final class AppContainer {

    // MARK: - Services

    lazy var eventKitCalendarService =
        EventKitCalendarService()

    lazy var speechRecognitionService =
        SpeechRecognitionService()

    lazy var commandParserService =
        CommandParserService()

    // MARK: - Repository

    lazy var calendarRepository =
        ICloudCalendarRepository(
            calendarService: eventKitCalendarService
        )

    // MARK: - UseCases

    lazy var requestCalendarAccessUseCase =
        RequestCalendarAccessUseCase(
            calendarRepository: calendarRepository
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

    // MARK: - ViewModels

    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            startVoiceRecognitionUseCase: startVoiceRecognitionUseCase,
            parseVoiceCommandUseCase: parseVoiceCommandUseCase,
            createCalendarEventUseCase: createCalendarEventUseCase
        )
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            requestCalendarAccessUseCase: requestCalendarAccessUseCase
        )
    }
}
