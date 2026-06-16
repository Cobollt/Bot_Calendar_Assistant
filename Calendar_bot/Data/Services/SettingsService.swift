import Foundation

final class SettingsService: SettingsServiceProtocol {

    private enum Keys {
        static let defaultReminderMinutes = "defaultReminderMinutes"
        static let defaultEventDurationMinutes = "defaultEventDurationMinutes"
        static let defaultEventHour = "defaultEventHour"
    }

    private let storage = UserDefaults.standard

    func getSettings() -> AppSettings {
        AppSettings(
            defaultReminderMinutes: storage.object(forKey: Keys.defaultReminderMinutes) as? Int
                ?? AppConstants.defaultReminderMinutes,

            defaultEventDurationMinutes: storage.object(forKey: Keys.defaultEventDurationMinutes) as? Int
                ?? AppConstants.defaultEventDurationMinutes,

            defaultEventHour: storage.object(forKey: Keys.defaultEventHour) as? Int
                ?? AppConstants.defaultEventHour
        )
    }

    func saveSettings(_ settings: AppSettings) {
        storage.set(settings.defaultReminderMinutes, forKey: Keys.defaultReminderMinutes)
        storage.set(settings.defaultEventDurationMinutes, forKey: Keys.defaultEventDurationMinutes)
        storage.set(settings.defaultEventHour, forKey: Keys.defaultEventHour)
    }
}
