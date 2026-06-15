import Foundation
import Speech
import AVFoundation

final class SpeechRecognitionService: SpeechRecognizerProtocol {

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var silenceTimer: Timer?

    func requestAccess() async throws {
        let microphoneGranted = await requestMicrophoneAccess()

        guard microphoneGranted else {
            throw SpeechError.microphoneAccessDenied
        }

        let speechGranted = await requestSpeechRecognitionAccess()

        guard speechGranted else {
            throw SpeechError.speechRecognitionDenied
        }
    }

    func startRecognition() async throws -> VoiceCommand {
        try await requestAccess()

        return try await withCheckedThrowingContinuation { continuation in
            do {
                try startRecording { text in
                    continuation.resume(
                        returning: VoiceCommand(
                            rawText: text,
                            createdAt: Date()
                        )
                    )
                }
            } catch {
                continuation.resume(throwing: SpeechError.recognitionFailed)
            }
        }
    }

    func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        recognitionTask?.cancel()
        recognitionTask = nil
        
        silenceTimer?.invalidate()
        silenceTimer = nil
    }

    private func startRecording(
        completion: @escaping (String) -> Void
    ) throws {
        recognitionTask?.cancel()
        recognitionTask = nil

        let audioSession = AVAudioSession.sharedInstance()

        try audioSession.setCategory(
            .record,
            mode: .measurement,
            options: .duckOthers
        )

        try audioSession.setActive(
            true,
            options: .notifyOthersOnDeactivation
        )

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        recognitionRequest = request

        guard let speechRecognizer,
              speechRecognizer.isAvailable
        else {
            throw SpeechError.recognitionFailed
        }

        var latestText = ""
        var didFinish = false

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in

            if let result {
                latestText = result.bestTranscription.formattedString

                self?.silenceTimer?.invalidate()

                self?.silenceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                    guard !didFinish else { return }

                    didFinish = true
                    self?.stopRecognition()

                    if !latestText.isEmpty {
                        completion(latestText)
                    }
                }

                if result.isFinal && !didFinish {
                    didFinish = true
                    self?.stopRecognition()
                    completion(latestText)
                }
            }

            if error != nil && !didFinish {
                didFinish = true
                self?.stopRecognition()
            }
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)

        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: format
        ) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    private func requestMicrophoneAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            switch AVAudioApplication.shared.recordPermission {
            case .granted:
                return true

            case .denied:
                return false

            case .undetermined:
                return await AVAudioApplication.requestRecordPermission()

            @unknown default:
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance()
                    .requestRecordPermission { granted in
                        continuation.resume(returning: granted)
                    }
            }
        }
    }

    private func requestSpeechRecognitionAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
