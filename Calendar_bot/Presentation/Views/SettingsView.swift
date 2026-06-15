import SwiftUI

struct SettingsView: View {

    @StateObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {

            Text("Настройки")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                permissionRow(
                    title: "Календарь",
                    isGranted: viewModel.hasCalendarAccess
                )

                permissionRow(
                    title: "Микрофон",
                    isGranted: viewModel.hasMicrophoneAccess
                )

                permissionRow(
                    title: "Распознавание речи",
                    isGranted: viewModel.hasSpeechAccess
                )
            }

            Button {
                Task {
                    await viewModel.requestCalendarAccess()
                }
            } label: {
                Text(
                    viewModel.hasCalendarAccess
                    ? "Доступ к календарю уже есть"
                    : "Разрешить доступ к календарю"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.hasCalendarAccess)

            Text(viewModel.statusMessage)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.refreshAccessStates()
        }
    }

    private func permissionRow(
        title: String,
        isGranted: Bool
    ) -> some View {
        HStack {
            Text(title)

            Spacer()

            Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isGranted ? .green : .red)
        }
        .padding()
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
