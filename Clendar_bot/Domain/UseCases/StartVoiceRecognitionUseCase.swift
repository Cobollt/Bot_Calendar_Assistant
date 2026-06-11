final class StartVoiceRecognitionUseCase {
    private let speechRecognizer: SpeechRecognizerProtocol

    init(speechRecognizer: SpeechRecognizerProtocol) {
        self.speechRecognizer = speechRecognizer
    }

    func execute() async throws -> VoiceCommand {
        try await speechRecognizer.startRecognition()
    }

    func stop() {
        speechRecognizer.stopRecognition()
    }
}
