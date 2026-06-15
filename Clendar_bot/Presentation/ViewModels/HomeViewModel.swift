import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var recognizedText = ""
    @Published var statusMessage = "Готов к работе"
    @Published var isProcessing = false
    @Published var hasCalendarAccess = false

    private let requestCalendarAccessUseCase: RequestCalendarAccessUseCase
    private let startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase
    private let parseVoiceCommandUseCase: ParseVoiceCommandUseCase
    private let createCalendarEventUseCase: CreateCalendarEventUseCase

    init(
        requestCalendarAccessUseCase: RequestCalendarAccessUseCase,
        startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase,
        parseVoiceCommandUseCase: ParseVoiceCommandUseCase,
        createCalendarEventUseCase: CreateCalendarEventUseCase
    ) {
        self.requestCalendarAccessUseCase = requestCalendarAccessUseCase
        self.startVoiceRecognitionUseCase = startVoiceRecognitionUseCase
        self.parseVoiceCommandUseCase = parseVoiceCommandUseCase
        self.createCalendarEventUseCase = createCalendarEventUseCase
        hasCalendarAccess =
        calendarRepository.hasCalendarAccess()
        
    }

    func requestCalendarAccess() async {
        
        guard hasCalendarAccess else {
            
            statusMessage =
            "Сначала разрешите доступ к календарю."

            return
        }
            
        do {
            statusMessage = "Запрашиваю доступ к календарю..."

            let granted = try await requestCalendarAccessUseCase.execute()

            statusMessage = granted
                ? "Доступ к календарю получен"
                : "Доступ к календарю запрещён"
            hasCalendarAccess = granted
        } catch {
            statusMessage = makeErrorMessage(from: error)
        }
    }

    func processVoiceCommand() async {
        isProcessing = true
        defer { isProcessing = false }
        
        guard hasCalendarAccess else {
            statusMessage = "Сначала разрешите доступ к календарю"
            return
        }

        do {
            statusMessage = "Получаю команду..."

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
            return "iCloud-календарь не найден"

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
