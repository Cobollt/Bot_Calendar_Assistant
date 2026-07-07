import Foundation

final class VoiceCommandFlow {

    private let startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase

    private let textNormalizer: TextNormalizerService
    private let intentParser: CommandIntentParserService

    private let createFlow: HomeCreateEventFlow
    private let deleteFlow: HomeDeleteEventFlow
    private let editFlow: HomeEditEventFlow

    init(
        startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase,
        textNormalizer: TextNormalizerService,
        intentParser: CommandIntentParserService,
        createFlow: HomeCreateEventFlow,
        deleteFlow: HomeDeleteEventFlow,
        editFlow: HomeEditEventFlow
    ) {
        self.startVoiceRecognitionUseCase = startVoiceRecognitionUseCase
        self.textNormalizer = textNormalizer
        self.intentParser = intentParser
        self.createFlow = createFlow
        self.deleteFlow = deleteFlow
        self.editFlow = editFlow
    }

    func execute() async throws -> VoiceCommandFlowResult {
        let command = try await startVoiceRecognitionUseCase.execute()

        let normalizedText = textNormalizer.normalize(command.rawText)

        let normalizedCommand = VoiceCommand(
            rawText: normalizedText,
            createdAt: command.createdAt
        )

        let intent = intentParser.parseIntent(
            from: normalizedText
        )

        switch intent {

        case .create:
            let action = try await createFlow.prepare(
                from: normalizedCommand
            )

            return .success(
                recognizedText: normalizedText,
                pendingAction: action
            )

        case .delete:
            guard let action = try await deleteFlow.prepare(
                from: normalizedCommand
            ) else {
                return .failure(
                    recognizedText: normalizedText,
                    message: "Событие для удаления не найдено."
                )
            }

            return .success(
                recognizedText: normalizedText,
                pendingAction: action
            )

        case .edit:
            guard let action = try await editFlow.prepare(
                from: normalizedCommand
            ) else {
                return .failure(
                    recognizedText: normalizedText,
                    message: "Не удалось подготовить редактирование события."
                )
            }

            return .success(
                recognizedText: normalizedText,
                pendingAction: action
            )

        case .unknown:
            return .failure(
                recognizedText: normalizedText,
                message: "Не удалось определить команду."
            )
        }
    }

    func stop() {
        startVoiceRecognitionUseCase.stop()
    }
}
