import Foundation

final class OpenSettingsUseCase {

    private let settingsOpener: SettingsOpenerProtocol

    init(
        settingsOpener: SettingsOpenerProtocol
    ) {
        self.settingsOpener = settingsOpener
    }

    func execute() {
        settingsOpener.openSettings()
    }
}
