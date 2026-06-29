import SwiftUI

struct SettingsView: View {

    @StateObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                permissionsSection

                eventSettingsSection

                toolsSection

                aboutSection
            }
            .padding()
        }
        .navigationTitle("Настройки")
        .onAppear {
            viewModel.refreshPermissions()
            viewModel.loadSettings()
        }
    }
}

// MARK: - Sections

private extension SettingsView {

    var permissionsSection: some View {
        settingsSection(title: "Разрешения") {
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

            Button {
                viewModel.openSettings()
            } label: {
                Text("Открыть настройки iPhone")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    var eventSettingsSection: some View {
        settingsSection(title: "Параметры событий") {
            Stepper(
                "Напоминание: \(viewModel.defaultReminderMinutes) мин.",
                value: $viewModel.defaultReminderMinutes,
                in: 0...180,
                step: 5
            )

            Stepper(
                "Длительность: \(viewModel.defaultEventDurationMinutes) мин.",
                value: $viewModel.defaultEventDurationMinutes,
                in: 15...240,
                step: 15
            )

            Stepper(
                "Время по умолчанию: \(viewModel.defaultEventHour):00",
                value: $viewModel.defaultEventHour,
                in: 0...23
            )

            Button {
                viewModel.saveSettings()
            } label: {
                Text("Сохранить настройки")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    var toolsSection: some View {
        settingsSection(title: "Инструменты") {
            Text("Здесь будут дополнительные функции приложения.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("Например: сброс пользовательских настроек, диагностика, проверка календаря.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    var aboutSection: some View {
        settingsSection(title: "О программе") {
            Text("Calendar Bot Assistant")
                .font(.headline)

            Text("Голосовой ассистент для создания событий в iCloud Calendar.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("Версия 1.0")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - UI Components

private extension SettingsView {

    func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)

            VStack(spacing: 12) {
                content()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    func permissionRow(
        title: String,
        isGranted: Bool
    ) -> some View {
        HStack {
            Text(title)

            Spacer()

            Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isGranted ? .green : .red)
        }
    }
}
