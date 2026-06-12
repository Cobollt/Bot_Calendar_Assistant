import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var recognizedText = ""

    @Published var statusMessage = ""

    @Published var isProcessing = false

    private let requestCalendarAccessUseCase:
        RequestCalendarAccessUseCase

    private let startVoiceRecognitionUseCase:
        StartVoiceRecognitionUseCase

    private let parseVoiceCommandUseCase:
        ParseVoiceCommandUseCase

    private let createCalendarEventUseCase:
        CreateCalendarEventUseCase

    init(
        requestCalendarAccessUseCase:
            RequestCalendarAccessUseCase,

        startVoiceRecognitionUseCase:
            StartVoiceRecognitionUseCase,

        parseVoiceCommandUseCase:
            ParseVoiceCommandUseCase,

        createCalendarEventUseCase:
            CreateCalendarEventUseCase
    ) {

        self.requestCalendarAccessUseCase =
            requestCalendarAccessUseCase

        self.startVoiceRecognitionUseCase =
            startVoiceRecognitionUseCase

        self.parseVoiceCommandUseCase =
            parseVoiceCommandUseCase

        self.createCalendarEventUseCase =
            createCalendarEventUseCase
    }
}
