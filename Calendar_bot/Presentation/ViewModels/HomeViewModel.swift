import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var recognizedText = ""
    @Published var statusMessage = "Готов к работе"
    @Published var isProcessing = false
    @Published var hasCalendarAccess = false
    @Published var pendingAction: HomePendingAction = .none

    private let checkPermissionsUseCase: CheckPermissionsUseCase
    private let createCalendarEventUseCase: CreateCalendarEventUseCase
    private let deleteCalendarEventUseCase: DeleteCalendarEventUseCase
    private let updateCalendarEventUseCase: UpdateCalendarEventUseCase
    private let openCalendarUseCase: OpenCalendarUseCase
    private let voiceCommandFlow: VoiceCommandFlow

    init(
        checkPermissionsUseCase: CheckPermissionsUseCase,
        createCalendarEventUseCase: CreateCalendarEventUseCase,
        deleteCalendarEventUseCase: DeleteCalendarEventUseCase,
        updateCalendarEventUseCase: UpdateCalendarEventUseCase,
        openCalendarUseCase: OpenCalendarUseCase,
        voiceCommandFlow: VoiceCommandFlow
    ) {
        self.checkPermissionsUseCase = checkPermissionsUseCase
        self.createCalendarEventUseCase = createCalendarEventUseCase
        self.deleteCalendarEventUseCase = deleteCalendarEventUseCase
        self.updateCalendarEventUseCase = updateCalendarEventUseCase
        self.openCalendarUseCase = openCalendarUseCase
        self.voiceCommandFlow = voiceCommandFlow

        refreshPermissions()
    }

    func refreshPermissions() {
        let permissions = checkPermissionsUseCase.execute()
        hasCalendarAccess = permissions.hasCalendarAccess
    }

    func openCalendar() {
        openCalendarUseCase.execute()
    }

    func processVoiceCommand() async {
        refreshPermissions()

        guard hasCalendarAccess else {
            statusMessage = "Сначала разрешите доступ к календарю в настройках."
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            clearPendingAction()
            statusMessage = "Слушаю..."

            let result = try await voiceCommandFlow.execute()

            switch result {
            case .success(let recognizedText, let pendingAction):
                self.recognizedText = recognizedText
                self.pendingAction = pendingAction
                self.statusMessage = makePreviewMessage(for: pendingAction)

            case .failure(let recognizedText, let message):
                self.recognizedText = recognizedText
                self.statusMessage = message
            }
        } catch {
            statusMessage = ErrorMessageMapper.map(error)
        }
    }

    func confirmPendingAction() async {
        switch pendingAction {

        case .none:
            statusMessage = "Нет действия для подтверждения"

        case .create(let event, _):
            await performConfirmedAction(
                processingMessage: "Создаю событие...",
                successMessage: "Событие добавлено в календарь"
            ) {
                try await createCalendarEventUseCase.execute(event)
            }

        case .delete(let event, _):
            await performConfirmedAction(
                processingMessage: "Удаляю событие...",
                successMessage: "Событие удалено"
            ) {
                try await deleteCalendarEventUseCase.execute(event)
            }

        case .move(let event, _):
            await performConfirmedAction(
                processingMessage: "Переношу событие...",
                successMessage: "Событие перенесено"
            ) {
                try await updateCalendarEventUseCase.execute(event)
            }

        case .updateReminder(let event, _):
            await performConfirmedAction(
                processingMessage: "Изменяю напоминание...",
                successMessage: "Напоминание изменено"
            ) {
                try await updateCalendarEventUseCase.execute(event)
            }
        }
    }

    func cancelPendingAction() {
        clearPendingAction()
        recognizedText = ""
        statusMessage = "Действие отменено"
    }

    private func performConfirmedAction(
        processingMessage: String,
        successMessage: String,
        action: () async throws -> Void
    ) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            statusMessage = processingMessage

            try await action()

            clearPendingAction()
            recognizedText = ""
            statusMessage = successMessage
        } catch {
            statusMessage = ErrorMessageMapper.map(error)
        }
    }

    private func makePreviewMessage(for action: HomePendingAction) -> String {
        switch action {
        case .none:
            return "Действие не подготовлено"
        case .create:
            return "Проверьте событие перед созданием"
        case .delete:
            return "Проверьте событие перед удалением"
        case .move:
            return "Проверьте новое время события"
        case .updateReminder:
            return "Проверьте новое напоминание"
        }
    }

    private func clearPendingAction() {
        pendingAction = .none
    }
}
