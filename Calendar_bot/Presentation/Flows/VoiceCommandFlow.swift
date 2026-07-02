import Foundation

final class VoiceCommandFlow {

    private let startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase

    private let textNormalizer: TextNormalizerService
    private let intentParser: CommandIntentParserService

    private let createFlow: HomeCreateEventFlow
    private let deleteFlow: HomeDeleteEventFlow
    private let moveFlow: HomeMoveEventFlow
    private let reminderFlow: HomeReminderUpdateFlow

    init(
        startVoiceRecognitionUseCase: StartVoiceRecognitionUseCase,

        textNormalizer: TextNormalizerService,
        intentParser: CommandIntentParserService,

        createFlow: HomeCreateEventFlow,
        deleteFlow: HomeDeleteEventFlow,
        moveFlow: HomeMoveEventFlow,
        reminderFlow: HomeReminderUpdateFlow
    ) {

        self.startVoiceRecognitionUseCase = startVoiceRecognitionUseCase

        self.textNormalizer = textNormalizer
        self.intentParser = intentParser

        self.createFlow = createFlow
        self.deleteFlow = deleteFlow
        self.moveFlow = moveFlow
        self.reminderFlow = reminderFlow
    }

    func execute() async throws -> VoiceCommandFlowResult {

        let command =
            try await startVoiceRecognitionUseCase.execute()

        let normalizedText =
            textNormalizer.normalize(command.rawText)

        let normalizedCommand = VoiceCommand(
            rawText: normalizedText,
            createdAt: command.createdAt
        )

        let intent =
            intentParser.parseIntent(
                from: normalizedText
            )

        switch intent {

        case .create:

            let action =
                try await createFlow.prepare(
                    from: normalizedCommand
                )

            return .success(
                recognizedText: normalizedText,
                pendingAction: action
            )

        case .delete:

            guard let action =
                try await deleteFlow.prepare(
                    from: normalizedCommand
                )
            else {
                return .failure(
                    recognizedText: normalizedText,
                    message: "Событие не найдено."
                )
            }

            return .success(
                recognizedText: normalizedText,
                pendingAction: action
            )

        case .move:

            guard let action =
                try await moveFlow.prepare(
                    from: normalizedCommand
                )
            else {
                return .failure(
                    recognizedText: normalizedText,
                    message: "Событие не найдено."
                )
            }

            return .success(
                recognizedText: normalizedText,
                pendingAction: action
            )

        case .updateReminder:

            let result =
                try await reminderFlow.prepare(
                    from: normalizedCommand
                )

            if let message = result.1 {

                return .failure(
                    recognizedText: normalizedText,
                    message: message
                )

            }

            guard let action = result.0 else {

                return .failure(
                    recognizedText: normalizedText,
                    message: "Событие не найдено."
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
}
