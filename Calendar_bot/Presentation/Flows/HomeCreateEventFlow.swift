import Foundation

final class HomeCreateEventFlow {

    private let startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase
    private let parseVoiceCommandUseCase: ParseVoiceCommandUseCase

    init(
        startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase,
        parseVoiceCommandUseCase: ParseVoiceCommandUseCase
    ) {
        self.startVoiceRecognitionUseCase = startVoiceRecognitionUseCase
        self.parseVoiceCommandUseCase = parseVoiceCommandUseCase
    }

    func prepare() async throws -> (VoiceCommand, HomePendingAction) {
        let command = try await startVoiceRecognitionUseCase.execute()
        let event = try parseVoiceCommandUseCase.execute(command)

        return (
            command,
            .create(
                event,
                EventPresentationMapper.map(event)
            )
        )
    }
}
