import Foundation

final class AppContainer {
    
    // MARK: - Services
    
    lazy var eventKitCalendarService =
    EventKitCalendarService()
    
    lazy var speechRecognitionService =
    SpeechRecognitionService()
    
    lazy var commandParserService =
    CommandParserService(
        settingsService: settingsService
    )
    
    lazy var calendarOpenerService =
    CalendarOpenerService()
    
    lazy var settingsService =
    SettingsService()
    
    lazy var permissionService =
    PermissionService()
    
    lazy var settingsOpenerService =
    SettingsOpenerService()
    
    
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
    
    lazy var getAppSettingsUseCase =
    GetAppSettingsUseCase(
        settingsService: settingsService
    )
    
    lazy var saveAppSettingsUseCase =
    SaveAppSettingsUseCase(
        settingsService: settingsService
    )
    
    lazy var openCalendarUseCase =
    OpenCalendarUseCase(
        calendarOpener: calendarOpenerService
    )
    
    lazy var openSettingsUseCase =
    OpenSettingsUseCase(
        settingsOpener:
            settingsOpenerService
    )
    
    // MARK: - ViewModels
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            checkPermissionsUseCase: checkPermissionsUseCase,
            startVoiceRecognitionUseCase: startVoiceRecognitionUseCase,
            parseVoiceCommandUseCase: parseVoiceCommandUseCase,
            createCalendarEventUseCase: createCalendarEventUseCase,
            openCalendarUseCase: openCalendarUseCase
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
