import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel: HomeViewModel
    private let settingsViewModel: SettingsViewModel

    init(
        viewModel: HomeViewModel,
        settingsViewModel: SettingsViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.settingsViewModel = settingsViewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                Text("Calendar Assistant")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(
                    viewModel.recognizedText.isEmpty
                    ? "Команда пока не получена"
                    : viewModel.recognizedText
                )
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if let event = viewModel.eventPreview {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Я понял команду так:")
                            .font(.headline)

                        Text("📌 \(event.title)")
                        Text("📅 \(event.date)")
                        Text("🕒 \(event.time)")
                        Text("🔔 \(event.reminder)")

                        HStack {
                            Button("Отмена") {
                                viewModel.cancelPendingEvent()
                            }
                            .buttonStyle(.bordered)

                            Spacer()

                            Button("Создать событие") {
                                Task {
                                    await viewModel.confirmEventCreation()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    Task {
                        await viewModel.processVoiceCommand()
                    }
                } label: {
                    Text(
                        viewModel.isProcessing
                        ? "Слушаю..."
                        : "Начать голосовой ввод"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    viewModel.isProcessing ||
                    !viewModel.hasCalendarAccess
                )
                
                Button {
                    viewModel.openCalendar()
                } label: {
                    Text("Открыть календарь")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                if !viewModel.hasCalendarAccess {
                    Text("Доступ к календарю нужно выдать в настройках.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Ассистент")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView(viewModel: settingsViewModel)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .onAppear {
                viewModel.refreshPermissions()
            }
        }
    }
}
