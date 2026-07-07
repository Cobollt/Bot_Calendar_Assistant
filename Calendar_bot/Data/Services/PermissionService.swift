import Foundation
import EventKit
import Speech
import AVFoundation
import UserNotifications

final class PermissionService: PermissionServiceProtocol {

    private let eventStore = EKEventStore()

    func checkPermissions() -> PermissionState {
        PermissionState(
            hasCalendarAccess: hasCalendarAccess(),
            hasMicrophoneAccess: hasMicrophoneAccess(),
            hasSpeechAccess: hasSpeechAccess()
        )
    }
    
    func requestAllPermissions() async throws -> PermissionState {
        _ = try await requestCalendarAccess()
        _ = await requestMicrophoneAccess()
        _ = await requestSpeechAccess()
        _ = try? await requestNotificationAccess()

        return checkPermissions()
    }
    
    private func requestMicrophoneAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    private func requestSpeechAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    private func requestNotificationAccess() async throws -> Bool {
        try await UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
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
