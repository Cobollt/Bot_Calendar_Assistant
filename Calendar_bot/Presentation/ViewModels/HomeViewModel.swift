import Foundation
import Combine
import EventKit

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var recognizedText = ""
    @Published var statusMessage = "Готов к работе"
    @Published var isProcessing = false
    @Published var hasCalendarAccess = false

    private let startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase
    private let parseVoiceCommandUseCase: ParseVoiceCommandUseCase
    private let createCalendarEventUseCase: CreateCalendarEventUseCase

    init(
        startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase,
        parseVoiceCommandUseCase: ParseVoiceCommandUseCase,
        createCalendarEventUseCase: CreateCalendarEventUseCase
    ) {
        self.startVoiceRecognitionUseCase = startVoiceRecognitionUseCase
        self.parseVoiceCommandUseCase = parseVoiceCommandUseCase
        self.createCalendarEventUseCase = createCalendarEventUseCase

        refreshCalendarAccess()
    }

    func refreshCalendarAccess() {
        let status = EKEventStore.authorizationStatus(for: .event)

        if #available(iOS 17.0, *) {
            hasCalendarAccess = status == .fullAccess
        } else {
            hasCalendarAccess = status == .authorized
        }
    }

    func processVoiceCommand() async {
        refreshCalendarAccess()

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

            statusMessage = "Создаю событие..."

            try await createCalendarEventUseCase.execute(event)

            statusMessage = "Событие добавлено в календарь"
        } catch {
            statusMessage = makeErrorMessage(from: error)
        }
    }

    private func makeErrorMessage(from error: Error) -> String {
        switch error {

        case CalendarError.accessDenied:
            return "Нет доступа к календарю"

        case CalendarError.calendarNotFound:
            return "Календарь не найден"

        case CalendarError.eventSaveFailed:
            return "Не удалось сохранить событие"

        case ParserError.emptyCommand:
            return "Команда пустая"

        case ParserError.invalidDate:
            return "Не удалось определить дату"

        case ParserError.emptyTitle:
            return "Не удалось определить название события"

        case SpeechError.microphoneAccessDenied:
            return "Нет доступа к микрофону"

        case SpeechError.speechRecognitionDenied:
            return "Нет доступа к распознаванию речи"

        case SpeechError.recognitionFailed:
            return "Не удалось распознать речь"

        default:
            return "Произошла неизвестная ошибка"
        }
    }
}
