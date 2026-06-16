import Foundation
import EventKit
import Speech
import AVFoundation

final class PermissionService: PermissionServiceProtocol {

    private let eventStore = EKEventStore()

    func checkPermissions() -> PermissionState {
        PermissionState(
            hasCalendarAccess: hasCalendarAccess(),
            hasMicrophoneAccess: hasMicrophoneAccess(),
            hasSpeechAccess: hasSpeechAccess()
        )
    }

    func requestCalendarAccess() async throws -> Bool {
        let granted = try await eventStore.requestFullAccessToEvents()

        guard granted else {
            throw CalendarError.accessDenied
        }

        return granted
    }

    private func hasCalendarAccess() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)

        if #available(iOS 17.0, *) {
            return status == .fullAccess
        } else {
            return status == .authorized
        }
    }

    private func hasMicrophoneAccess() -> Bool {
        if #available(iOS 17.0, *) {
            return AVAudioApplication.shared.recordPermission == .granted
        } else {
            return AVAudioSession.sharedInstance().recordPermission == .granted
        }
    }

    private func hasSpeechAccess() -> Bool {
        SFSpeechRecognizer.authorizationStatus() == .authorized
    }
}
