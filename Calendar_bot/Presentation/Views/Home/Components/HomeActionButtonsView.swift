import SwiftUI

struct HomeActionButtonsView: View {

    let isProcessing: Bool
    let hasCalendarAccess: Bool

    let onVoiceCommand: () -> Void
    let onOpenCalendar: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button {
                onVoiceCommand()
            } label: {
                Text(isProcessing ? "Слушаю..." : "Начать голосовой ввод")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isProcessing || !hasCalendarAccess)

            Button {
                onOpenCalendar()
            } label: {
                Text("Открыть календарь")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}
