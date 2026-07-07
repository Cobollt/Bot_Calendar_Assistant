import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {

    @Published var hasCalendarAccess = false
    @Published var hasMicrophoneAccess = false
    @Published var hasSpeechAccess = false
    @Published var statusMessage = ""

    @Published var defaultReminderMinutes = 30
    @Published var defaultEventDurationMinutes = 60
    @Published var defaultEventHour = 9

    private let checkPermissionsUseCase: CheckPermissionsUseCase
    private let requestCalendarAccessUseCase: RequestCalendarAccessUseCase
    private let getAppSettingsUseCase: GetAppSettingsUseCase
    private let saveAppSettingsUseCase: SaveAppSettingsUseCase
    private let openSettingsUseCase: OpenSettingsUseCase
    private let requestAllPermissionsUseCase: RequestAllPermissionsUseCase

    init(
        checkPermissionsUseCase: CheckPermissionsUseCase,
        requestCalendarAccessUseCase: RequestCalendarAccessUseCase,
        requestAllPermissionsUseCase: RequestAllPermissionsUseCase,
        getAppSettingsUseCase: GetAppSettingsUseCase,
        saveAppSettingsUseCase: SaveAppSettingsUseCase,
        openSettingsUseCase: OpenSettingsUseCase
    ) {
        self.checkPermissionsUseCase = checkPermissionsUseCase
        self.requestCalendarAccessUseCase = requestCalendarAccessUseCase
        self.requestAllPermissionsUseCase = requestAllPermissionsUseCase
        self.getAppSettingsUseCase = getAppSettingsUseCase
        self.saveAppSettingsUseCase = saveAppSettingsUseCase
        self.openSettingsUseCase = openSettingsUseCase

        refreshPermissions()
        loadSettings()
    }

    func refreshPermissions() {
        let permissions = checkPermissionsUseCase.execute()

        hasCalendarAccess = permissions.hasCalendarAccess
        hasMicrophoneAccess = permissions.hasMicrophoneAccess
        hasSpeechAccess = permissions.hasSpeechAccess
    }
    
    func requestAllPermissions() async {
        do {
            let permissions = try await requestAllPermissionsUseCase.execute()

            hasCalendarAccess = permissions.hasCalendarAccess
            hasMicrophoneAccess = permissions.hasMicrophoneAccess
            hasSpeechAccess = permissions.hasSpeechAccess

            statusMessage = "Разрешения обновлены"
        } catch {
            statusMessage = "Не удалось получить все разрешения"
            refreshPermissions()
        }
    }

    func requestCalendarAccess() async {
        do {
            let granted = try await requestCalendarAccessUseCase.execute()

            hasCalendarAccess = granted
            statusMessage = granted
                ? "Доступ к календарю получен"
                : "Доступ к календарю запрещён"

            refreshPermissions()
        } catch {
            hasCalendarAccess = false
            statusMessage = "Не удалось получить доступ к календарю"
        }
    }
    
    func openSettings() {
        openSettingsUseCase.execute()
    }

    func loadSettings() {
        let settings = getAppSettingsUseCase.execute()

        defaultReminderMinutes = settings.defaultReminderMinutes
        defaultEventDurationMinutes = settings.defaultEventDurationMinutes
        defaultEventHour = settings.defaultEventHour
    }

    func saveSettings() {
        let settings = AppSettings(
            defaultReminderMinutes: defaultReminderMinutes,
            defaultEventDurationMinutes: defaultEventDurationMinutes,
            defaultEventHour: defaultEventHour
        )

        saveAppSettingsUseCase.execute(settings)

        statusMessage = "Настройки сохранены"
    }
}
