import Foundation

final class GetAppSettingsUseCase {

    private let settingsService: SettingsServiceProtocol

    init(settingsService: SettingsServiceProtocol) {
        self.settingsService = settingsService
    }

    func execute() -> AppSettings {
        settingsService.getSettings()
    }
}
