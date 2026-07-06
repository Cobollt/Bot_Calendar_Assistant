import Foundation

protocol SpeechRecognizerProtocol {
    func startRecognition() async throws -> VoiceCommand
    func stopRecognition()
}
