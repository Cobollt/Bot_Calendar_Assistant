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

    private let checkPermissionsUseCase: CheckPermissionsUseCase
    private let startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase
    private let parseVoiceCommandUseCase: ParseVoiceCommandUseCase
    private let createCalendarEventUseCase: CreateCalendarEventUseCase
    private let openCalendarUseCase: OpenCalendarUseCase

    init(
        checkPermissionsUseCase: CheckPermissionsUseCase,
        startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase,
        parseVoiceCommandUseCase: ParseVoiceCommandUseCase,
        createCalendarEventUseCase: CreateCalendarEventUseCase,
        openCalendarUseCase: OpenCalendarUseCase
    ) {
        self.checkPermissionsUseCase = checkPermissionsUseCase
        self.startVoiceRecognitionUseCase = startVoiceRecognitionUseCase
        self.parseVoiceCommandUseCase = parseVoiceCommandUseCase
        self.createCalendarEventUseCase = createCalendarEventUseCase
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
}
