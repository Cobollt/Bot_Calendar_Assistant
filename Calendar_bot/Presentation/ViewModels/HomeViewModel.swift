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

    private let createEventFlow: HomeCreateEventFlow
    private let deleteEventFlow: HomeDeleteEventFlow
    private let moveEventFlow: HomeMoveEventFlow
    private let reminderUpdateFlow: HomeReminderUpdateFlow

    init(
        checkPermissionsUseCase: CheckPermissionsUseCase,
        createCalendarEventUseCase: CreateCalendarEventUseCase,
        deleteCalendarEventUseCase: DeleteCalendarEventUseCase,
        updateCalendarEventUseCase: UpdateCalendarEventUseCase,
        openCalendarUseCase: OpenCalendarUseCase,
        createEventFlow: HomeCreateEventFlow,
        deleteEventFlow: HomeDeleteEventFlow,
        moveEventFlow: HomeMoveEventFlow,
        reminderUpdateFlow: HomeReminderUpdateFlow
    ) {
        self.checkPermissionsUseCase = checkPermissionsUseCase
        self.createCalendarEventUseCase = createCalendarEventUseCase
        self.deleteCalendarEventUseCase = deleteCalendarEventUseCase
        self.updateCalendarEventUseCase = updateCalendarEventUseCase
        self.openCalendarUseCase = openCalendarUseCase

        self.createEventFlow = createEventFlow
        self.deleteEventFlow = deleteEventFlow
        self.moveEventFlow = moveEventFlow
        self.reminderUpdateFlow = reminderUpdateFlow

        refreshPermissions()
    }

    func refreshPermissions() {
        let permissions = checkPermissionsUseCase.execute()
        hasCalendarAccess = permissions.hasCalendarAccess
    }

    func openCalendar() {
        openCalendarUseCase.execute()
    }

    func prepareCreateEvent() async {
        await runPrepareFlow(
            listeningMessage: "Слушаю...",
            successMessage: "Проверьте событие перед созданием"
        ) {
            let result = try await createEventFlow.prepare()
            return (result.0, result.1, nil)
        }
    }

    func prepareDeleteEvent() async {
        await runPrepareFlow(
            listeningMessage: "Слушаю команду удаления...",
            successMessage: "Проверьте событие перед удалением"
        ) {
            let result = try await deleteEventFlow.prepare()

            return (
                result.0,
                result.1,
                result.1 == nil ? "Событие для удаления не найдено" : nil
            )
        }
    }

    func prepareMoveEvent() async {
        await runPrepareFlow(
            listeningMessage: "Слушаю команду переноса...",
            successMessage: "Проверьте новое время события"
        ) {
            let result = try await moveEventFlow.prepare()

            return (
                result.0,
                result.1,
                result.1 == nil ? "Событие для переноса не найдено" : nil
            )
        }
    }

    func prepareReminderUpdate() async {
        await runPrepareFlow(
            listeningMessage: "Слушаю команду изменения напоминания...",
            successMessage: "Проверьте новое напоминание"
        ) {
            let result = try await reminderUpdateFlow.prepare()

            return (
                result.0,
                result.1,
                result.2
            )
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

    private func runPrepareFlow(
        listeningMessage: String,
        successMessage: String,
        action: () async throws -> (VoiceCommand, HomePendingAction?, String?)
    ) async {
        refreshPermissions()

        guard hasCalendarAccess else {
            statusMessage = "Сначала разрешите доступ к календарю в настройках."
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            clearPendingAction()
            statusMessage = listeningMessage

            let result = try await action()

            recognizedText = result.0.rawText

            if let message = result.2 {
                statusMessage = message
                return
            }

            guard let pendingAction = result.1 else {
                statusMessage = "Действие не подготовлено"
                return
            }

            self.pendingAction = pendingAction
            statusMessage = successMessage
        } catch {
            statusMessage = ErrorMessageMapper.map(error)
        }
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

    private func clearPendingAction() {
        pendingAction = .none
    }
}
