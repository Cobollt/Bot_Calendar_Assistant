import Foundation

final class SpeechRecognitionService: SpeechRecognizerProtocol {
    
    func requestAccess() async throws -> Bool {
        //доступ к микрофону
        return true
    }
    
    func startRecognition() async throws -> VoiceCommand {
        //распознование речи
        return VoiceCommand(
            rawText: "позвонить",
            createdAt: Date()
        )
    }
    
    func stopRecognition() {
        //AVAudioEngine
    }
}
