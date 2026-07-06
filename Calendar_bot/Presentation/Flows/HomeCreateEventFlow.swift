import Foundation

final class HomeCreateEventFlow {

    private let parseVoiceCommandUseCase: ParseVoiceCommandUseCase

    init(
        parseVoiceCommandUseCase: ParseVoiceCommandUseCase
    ) {
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
