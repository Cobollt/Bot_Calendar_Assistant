import Foundation

enum VoiceCommandFlowResult {

    case success(
        recognizedText: String,
        pendingAction: HomePendingAction
    )

    case failure(
        recognizedText: String,
        message: String
    )

}
