import Foundation
import Combine
import EventKit
import Speech
import AVFoundation

@MainActor
final class SettingsViewModel: ObservableObject {

    @Published var hasCalendarAccess = false
    @Published var hasMicrophoneAccess = false
    @Published var hasSpeechAccess = false
    @Published var statusMessage = ""

    private let requestCalendarAccessUseCase: RequestCalendarAccessUseCase

    init(
        requestCalendarAccessUseCase: RequestCalendarAccessUseCase
    ) {
        self.requestCalendarAccessUseCase = requestCalendarAccessUseCase
        refreshAccessStates()
    }

    func refreshAccessStates() {
        refreshCalendarAccess()
        refreshMicrophoneAccess()
        refreshSpeechAccess()
    }

    func requestCalendarAccess() async {
        do {
            let granted = try await requestCalendarAccessUseCase.execute()

            hasCalendarAccess = granted
            statusMessage = granted
                ? "Доступ к календарю получен"
                : "Доступ к календарю запрещён"
        } catch {
            hasCalendarAccess = false
            statusMessage = "Не удалось получить доступ к календарю"
        }
    }

    private func refreshCalendarAccess() {
        let status = EKEventStore.authorizationStatus(for: .event)

        if #available(iOS 17.0, *) {
            hasCalendarAccess = status == .fullAccess
        } else {
            hasCalendarAccess = status == .authorized
        }
    }

    private func refreshMicrophoneAccess() {
        if #available(iOS 17.0, *) {
            hasMicrophoneAccess = AVAudioApplication.shared.recordPermission == .granted
        } else {
            hasMicrophoneAccess = AVAudioSession.sharedInstance().recordPermission == .granted
        }
    }

    private func refreshSpeechAccess() {
        hasSpeechAccess = SFSpeechRecognizer.authorizationStatus() == .authorized
    }
}
