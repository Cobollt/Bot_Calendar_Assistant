import Foundation

enum SpeechError: Error {
    case microphoneAccessDenied
    case speechRecognitionDenied
    case recognitionFailed
}
