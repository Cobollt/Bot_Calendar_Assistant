import Foundation


protocol SpeechRecognizerProtocol {
    func requestAccess() async throws -> Bool
    func startRecognition () async throws -> VoiceCommand
    func stopRecognition ()
}
