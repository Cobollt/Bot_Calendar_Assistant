import Foundation

final class SaveAppSettingsUseCase {

    private let settingsService: SettingsServiceProtocol

    init(settingsService: SettingsServiceProtocol) {
        self.settingsService = settingsService
    }

    func execute(_ settings: AppSettings) {
        settingsService.saveSettings(settings)
    }
}
