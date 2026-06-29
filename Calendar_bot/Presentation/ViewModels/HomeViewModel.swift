import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var recognizedText = ""
    @Published var statusMessage = "Готов к работе"
    @Published var isProcessing = false
    @Published var hasCalendarAccess = false

    @Published var pendingEvent: CalendarEvent?
    @Published var eventPreview: EventPresentation?
    @Published var pendingDeleteEvent: CalendarEvent?
    @Published var deletePreview: EventPresentation?
    @Published var pendingUpdateEvent: CalendarEvent?
    @Published var updatePreview: EventPresentation?
    @Published var pendingReminderUpdateEvent: CalendarEvent?
    @Published var reminderUpdatePreview: EventPresentation?

    private let checkPermissionsUseCase: CheckPermissionsUseCase
    private let startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase
    private let parseVoiceCommandUseCase: ParseVoiceCommandUseCase
    private let createCalendarEventUseCase: CreateCalendarEventUseCase
    private let openCalendarUseCase: OpenCalendarUseCase
    private let findCalendarEventsUseCase: FindCalendarEventsUseCase
    private let deleteCalendarEventUseCase: DeleteCalendarEventUseCase
    private let updateCalendarEventUseCase: UpdateCalendarEventUseCase

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
    
    func openCalendar() {
        openCalendarUseCase.execute()
    }

    func refreshPermissions() {
        let permissions = checkPermissionsUseCase.execute()
        hasCalendarAccess = permissions.hasCalendarAccess
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
            statusMessage = "Слушаю..."

            let command = try await startVoiceRecognitionUseCase.execute()
            recognizedText = command.rawText

            statusMessage = "Разбираю команду..."

            let event = try parseVoiceCommandUseCase.execute(command)

            pendingEvent = event
            eventPreview = EventPresentationMapper.map(event)

            statusMessage = "Проверьте событие перед созданием"
        } catch {
            statusMessage = ErrorMessageMapper.map(error)
        }
    }

    func confirmEventCreation() async {
        guard let event = pendingEvent else {
            statusMessage = "Нет события для создания"
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            statusMessage = "Создаю событие..."

            try await createCalendarEventUseCase.execute(event)

            statusMessage = "Событие добавлено в календарь"

            pendingEvent = nil
            eventPreview = nil
            recognizedText = ""
        } catch {
            statusMessage = ErrorMessageMapper.map(error)
        }
    }

    func cancelPendingEvent() {
        pendingEvent = nil
        eventPreview = nil
        recognizedText = ""
        statusMessage = "Создание события отменено"
    }
    
    func prepareDeleteEvent() async {
        refreshPermissions()

        guard hasCalendarAccess else {
            statusMessage = "Сначала разрешите доступ к календарю в настройках."
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            statusMessage = "Слушаю команду удаления..."

            let command = try await startVoiceRecognitionUseCase.execute()
            recognizedText = command.rawText

            let searchText = command.rawText
                .lowercased()
                .replacingOccurrences(of: "отмени", with: "")
                .replacingOccurrences(of: "удали", with: "")
                .replacingOccurrences(of: "событие", with: "")
                .replacingOccurrences(of: "встречу", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)

            let calendar = Calendar.current
            let now = Date()
            let endDate = calendar.date(byAdding: .day, value: 30, to: now) ?? now

            let events = try await findCalendarEventsUseCase.execute(
                matching: searchText,
                from: now,
                to: endDate
            )

            guard let event = events.first else {
                statusMessage = "Событие для удаления не найдено"
                return
            }

            pendingDeleteEvent = event
            deletePreview = EventPresentationMapper.map(event)

            statusMessage = "Проверьте событие перед удалением"
        } catch {
            statusMessage = ErrorMessageMapper.map(error)
        }
    }
    
    func prepareReminderUpdate() async {
        refreshPermissions()

        guard hasCalendarAccess else {
            statusMessage = "Сначала разрешите доступ к календарю в настройках."
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            statusMessage = "Слушаю команду изменения напоминания..."

            let command = try await startVoiceRecognitionUseCase.execute()
            recognizedText = command.rawText

            let reminderMinutes = extractReminderMinutes(from: command.rawText)

            guard let reminderMinutes else {
                statusMessage = "Не удалось определить новое время напоминания"
                return
            }

            let searchText = makeSearchTextForReminderUpdate(from: command.rawText)

            let calendar = Calendar.current
            let now = Date()
            let searchEndDate = calendar.date(byAdding: .day, value: 60, to: now) ?? now

            let events = try await findCalendarEventsUseCase.execute(
                matching: searchText,
                from: now,
                to: searchEndDate
            )

            guard let event = events.first else {
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
                reminder: Reminder(minutesBefore: reminderMinutes),
                recurrenceRule: event.recurrenceRule
            )

            pendingReminderUpdateEvent = updatedEvent
            reminderUpdatePreview = EventPresentationMapper.map(updatedEvent)

            statusMessage = "Проверьте новое напоминание"
        } catch {
            statusMessage = ErrorMessageMapper.map(error)
        }
    }
    
    func confirmReminderUpdate() async {
        guard let event = pendingReminderUpdateEvent else {
            statusMessage = "Нет события для изменения"
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            statusMessage = "Изменяю напоминание..."

            try await updateCalendarEventUseCase.execute(event)

            pendingReminderUpdateEvent = nil
            reminderUpdatePreview = nil
            recognizedText = ""

            statusMessage = "Напоминание изменено"
        } catch {
            statusMessage = ErrorMessageMapper.map(error)
        }
    }
    
    func cancelReminderUpdate() {
        pendingReminderUpdateEvent = nil
        reminderUpdatePreview = nil
        recognizedText = ""
        statusMessage = "Изменение напоминания отменено"
    }
    
    private func extractReminderMinutes(from text: String) -> Int? {
        let lowercasedText = text.lowercased()

        if lowercasedText.contains("без напоминания") {
            return 0
        }

        if lowercasedText.contains("за час") ||
            lowercasedText.contains("на час") {
            return 60
        }

        if lowercasedText.contains("за полчаса") ||
            lowercasedText.contains("на полчаса") {
            return 30
        }

        if lowercasedText.contains("за день") ||
            lowercasedText.contains("на день") {
            return 24 * 60
        }

        let minutePattern = #"(?i)(?:за|на)\s+(\d{1,3})\s+(?:минут|минуты|минуту)"#

        if let minutes = extractNumber(
            from: lowercasedText,
            pattern: minutePattern
        ) {
            return minutes
        }

        let hourPattern = #"(?i)(?:за|на)\s+(\d{1,2})\s+(?:час|часа|часов)"#

        if let hours = extractNumber(
            from: lowercasedText,
            pattern: hourPattern
        ) {
            return hours * 60
        }

        return nil
    }

    private func makeSearchTextForReminderUpdate(from text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "измени", with: "")
            .replacingOccurrences(of: "поменяй", with: "")
            .replacingOccurrences(of: "напоминание", with: "")
            .replacingOccurrences(of: "на час", with: "")
            .replacingOccurrences(of: "за час", with: "")
            .replacingOccurrences(of: "на полчаса", with: "")
            .replacingOccurrences(of: "за полчаса", with: "")
            .replacingOccurrences(of: "без напоминания", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractNumber(
        from text: String,
        pattern: String
    ) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: text,
                range: NSRange(text.startIndex..., in: text)
              ),
              let range = Range(match.range(at: 1), in: text)
        else {
            return nil
        }

        return Int(text[range])
    }
    
    func prepareMoveEvent() async {
        refreshPermissions()

        guard hasCalendarAccess else {
            statusMessage = "Сначала разрешите доступ к календарю в настройках."
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            statusMessage = "Слушаю команду переноса..."

            let command = try await startVoiceRecognitionUseCase.execute()
            recognizedText = command.rawText

            let searchText = makeSearchTextForMove(from: command.rawText)

            let calendar = Calendar.current
            let now = Date()
            let searchEndDate = calendar.date(
                byAdding: .day,
                value: 60,
                to: now
            ) ?? now

            let events = try await findCalendarEventsUseCase.execute(
                matching: searchText,
                from: now,
                to: searchEndDate
            )

            guard let event = events.first else {
                statusMessage = "Событие для переноса не найдено"
                return
            }

            let newEvent = try makeMovedEvent(
                originalEvent: event,
                commandText: command.rawText
            )

            pendingUpdateEvent = newEvent
            updatePreview = EventPresentationMapper.map(newEvent)

            statusMessage = "Проверьте новое время события"
        } catch {
            statusMessage = ErrorMessageMapper.map(error)
        }
    }
    
    func confirmMoveEvent() async {
        guard let event = pendingUpdateEvent else {
            statusMessage = "Нет события для переноса"
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            statusMessage = "Переношу событие..."

            try await updateCalendarEventUseCase.execute(event)

            pendingUpdateEvent = nil
            updatePreview = nil
            recognizedText = ""

            statusMessage = "Событие перенесено"
        } catch {
            statusMessage = ErrorMessageMapper.map(error)
        }
    }
    
    func cancelMoveEvent() {
        pendingUpdateEvent = nil
        updatePreview = nil
        recognizedText = ""
        statusMessage = "Перенос отменён"
    }
    
    private func makeSearchTextForMove(from text: String) -> String {
        text
            .lowercased()
            .replacingOccurrences(of: "перенеси", with: "")
            .replacingOccurrences(of: "перенести", with: "")
            .replacingOccurrences(of: "событие", with: "")
            .replacingOccurrences(of: "встречу", with: "")
            .replacingOccurrences(of: "на час позже", with: "")
            .replacingOccurrences(of: "на час раньше", with: "")
            .replacingOccurrences(of: "на 30 минут позже", with: "")
            .replacingOccurrences(of: "на 30 минут раньше", with: "")
            .replacingOccurrences(of: "на следующий понедельник", with: "")
            .replacingOccurrences(of: "на следующую пятницу", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func makeMovedEvent(
        originalEvent: CalendarEvent,
        commandText: String
    ) throws -> CalendarEvent {
        let lowercasedText = commandText.lowercased()

        let duration = originalEvent.endDate.timeIntervalSince(
            originalEvent.startDate
        )

        let newStartDate: Date

        if lowercasedText.contains("на час позже") {
            newStartDate = originalEvent.startDate.addingTimeInterval(60 * 60)
        } else if lowercasedText.contains("на час раньше") {
            newStartDate = originalEvent.startDate.addingTimeInterval(-60 * 60)
        } else if lowercasedText.contains("на 30 минут позже") {
            newStartDate = originalEvent.startDate.addingTimeInterval(30 * 60)
        } else if lowercasedText.contains("на 30 минут раньше") {
            newStartDate = originalEvent.startDate.addingTimeInterval(-30 * 60)
        } else {
            let voiceCommand = VoiceCommand(
                rawText: commandText,
                createdAt: Date()
            )

            let parsedEvent = try parseVoiceCommandUseCase.execute(voiceCommand)
            newStartDate = parsedEvent.startDate
        }

        let newEndDate = newStartDate.addingTimeInterval(duration)

        return CalendarEvent(
            id: originalEvent.id,
            externalIdentifier: originalEvent.externalIdentifier,
            title: originalEvent.title,
            startDate: newStartDate,
            endDate: newEndDate,
            notes: originalEvent.notes,
            reminder: originalEvent.reminder,
            recurrenceRule: originalEvent.recurrenceRule
        )
    }
    
    func confirmDeleteEvent() async {
        guard let event = pendingDeleteEvent else {
            statusMessage = "Нет события для удаления"
            return
        }

        isProcessing = true
        defer { isProcessing = false }

        do {
            statusMessage = "Удаляю событие..."

            try await deleteCalendarEventUseCase.execute(event)

            pendingDeleteEvent = nil
            deletePreview = nil
            recognizedText = ""

            statusMessage = "Событие удалено"
        } catch {
            statusMessage = ErrorMessageMapper.map(error)
        }
    }
    
    func cancelDeleteEvent() {
        pendingDeleteEvent = nil
        deletePreview = nil
        recognizedText = ""
        statusMessage = "Удаление отменено"
    }
}
