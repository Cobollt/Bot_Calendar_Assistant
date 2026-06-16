import Foundation

protocol SettingsServiceProtocol {
    func getSettings() -> AppSettings
    func saveSettings(_ settings: AppSettings)
}
