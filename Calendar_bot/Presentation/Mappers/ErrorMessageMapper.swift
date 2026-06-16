import Foundation

enum ErrorMessageMapper {

    static func map(_ error: Error) -> String {
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
