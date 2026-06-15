import Foundation


protocol SpeechRecognizerProtocol {
    func requestAccess() async throws
    func startRecognition () async throws -> VoiceCommand
    func stopRecognition ()
}
