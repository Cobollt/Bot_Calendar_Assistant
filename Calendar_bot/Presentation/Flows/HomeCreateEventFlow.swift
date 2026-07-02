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

    func prepare(from command: VoiceCommand) async throws -> HomePendingAction {
        let event = try parseVoiceCommandUseCase.execute(command)

        return .create(
            event,
            EventPresentationMapper.map(event)
        )
    }
}
