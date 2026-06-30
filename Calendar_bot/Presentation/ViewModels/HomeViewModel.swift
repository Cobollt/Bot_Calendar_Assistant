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
    private let startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase
    private let parseVoiceCommandUseCase: ParseVoiceCommandUseCase
    private let createCalendarEventUseCase: CreateCalendarEventUseCase
    private let findCalendarEventsUseCase: FindCalendarEventsUseCase
    private let deleteCalendarEventUseCase: DeleteCalendarEventUseCase
    private let updateCalendarEventUseCase: UpdateCalendarEventUseCase
    private let openCalendarUseCase: OpenCalendarUseCase

    init(
        checkPermissionsUseCase: CheckPermissionsUseCase,
        startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase,
        parseVoiceCommandUseCase: ParseVoiceCommandUseCase,
        createCalendarEventUseCase: CreateCalendarEventUseCase,
        findCalendarEventsUseCase: FindCalendarEventsUseCase,
        deleteCalendarEventUseCase: DeleteCalendarEventUseCase,
        updateCalendarEventUseCase: UpdateCalendarEventUseCase,
        openCalendarUseCase: OpenCalendarUseCase
    ) {
        self.checkPermissionsUseCase = checkPermissionsUseCase
        self.startVoiceRecognitionUseCase = startVoiceRecognitionUseCase
        self.parseVoiceCommandUseCase = parseVoiceCommandUseCase
        self.createCalendarEventUseCase = createCalendarEventUseCase
        self.findCalendarEventsUseCase = findCalendarEventsUseCase
        self.deleteCalendarEventUseCase = deleteCalendarEventUseCase
        self.updateCalendarEventUseCase = updateCalendarEventUseCase
        self.openCalendarUseCase = openCalendarUseCase

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
        await runVoiceFlow(
            listeningMessage: "Слушаю...",
            failureMessage: "Не удалось подготовить событие"
        ) { command in
            let event = try parseVoiceCommandUseCase.execute(command)

            pendingAction = .create(
                event,
                EventPresentationMapper.map(event)
            )

            statusMessage = "Проверьте событие перед созданием"
        }
    }

    func prepareDeleteEvent() async {
        await runVoiceFlow(
            listeningMessage: "Слушаю команду удаления...",
            failureMessage: "Событие для удаления не найдено"
        ) { command in
            let searchText = HomeEventCommandMapper.makeDeleteSearchText(
                from: command.rawText
            )

            guard let event = try await findFirstEvent(matching: searchText) else {
                statusMessage = "Событие для удаления не найдено"
                return
            }

            pendingAction = .delete(
                event,
                EventPresentationMapper.map(event)
            )

            statusMessage = "Проверьте событие перед удалением"
        }
    }

    func prepareMoveEvent() async {
        await runVoiceFlow(
            listeningMessage: "Слушаю команду переноса...",
            failureMessage: "Событие для переноса не найдено"
        ) { command in
            let searchText = HomeEventCommandMapper.makeMoveSearchText(
                from: command.rawText
            )

            guard let event = try await findFirstEvent(matching: searchText) else {
                statusMessage = "Событие для переноса не найдено"
                return
            }

            let movedEvent = try HomeEventCommandMapper.makeMovedEvent(
                originalEvent: event,
                commandText: command.rawText,
                parseVoiceCommandUseCase: parseVoiceCommandUseCase
            )

            pendingAction = .move(
                movedEvent,
                EventPresentationMapper.map(movedEvent)
            )

            statusMessage = "Проверьте новое время события"
        }
    }

    func prepareReminderUpdate() async {
        await runVoiceFlow(
            listeningMessage: "Слушаю команду изменения напоминания...",
            failureMessage: "Событие для изменения напоминания не найдено"
        ) { command in
            guard let reminderMinutes = HomeEventCommandMapper
                .extractReminderMinutes(from: command.rawText)
            else {
                statusMessage = "Не удалось определить новое время напоминания"
                return
            }

            let searchText = HomeEventCommandMapper.makeReminderSearchText(
                from: command.rawText
            )

            guard let event = try await findFirstEvent(matching: searchText) else {
                statusMessage = "Событие для изменения напоминания не найдено"
                return
            }

            let updatedEvent = CalendarEvent(
                id: event.id,
                externalIdentifier: event.externalIdentifier,
                title: event.title,
                startDate: event.startDate,
                endDate: event.endDate,
                notes: event.notes,
                reminder: reminderMinutes == 0
                    ? nil
                    : Reminder(minutesBefore: reminderMinutes),
                recurrenceRule: event.recurrenceRule
            )

            pendingAction = .updateReminder(
                updatedEvent,
                EventPresentationMapper.map(updatedEvent)
            )

            statusMessage = "Проверьте новое напоминание"
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
        pendingAction = .none
        recognizedText = ""
        statusMessage = "Действие отменено"
    }

    private func runVoiceFlow(
        listeningMessage: String,
        failureMessage: String,
        action: (VoiceCommand) async throws -> Void
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

            let command = try await startVoiceRecognitionUseCase.execute()
            recognizedText = command.rawText

            try await action(command)
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

    private func findFirstEvent(
        matching text: String?
    ) async throws -> CalendarEvent? {
        let calendar = Calendar.current
        let now = Date()
        let endDate = calendar.date(
            byAdding: .day,
            value: 60,
            to: now
        ) ?? now

        let events = try await findCalendarEventsUseCase.execute(
            matching: text,
            from: now,
            to: endDate
        )

        return events.first
    }

    private func clearPendingAction() {
        pendingAction = .none
    }
}
