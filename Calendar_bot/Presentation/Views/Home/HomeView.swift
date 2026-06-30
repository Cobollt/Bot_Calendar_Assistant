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
                        Text("🔁 \(event.recurrence)")
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
                
                if let event = viewModel.deletePreview {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Удалить это событие?")
                            .font(.headline)

                        Text("📌 \(event.title)")
                        Text("📅 \(event.date)")
                        Text("🕒 \(event.time)")
                        Text("🔔 \(event.reminder)")

                        HStack {
                            Button("Отмена") {
                                viewModel.cancelDeleteEvent()
                            }
                            .buttonStyle(.bordered)

                            Spacer()

                            Button("Удалить") {
                                Task {
                                    await viewModel.confirmDeleteEvent()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            
                            Button {
                                Task {
                                    await viewModel.prepareDeleteEvent()
                                }
                            } label: {
                                Text("Удалить событие голосом")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.isProcessing || !viewModel.hasCalendarAccess)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                if let event = viewModel.updatePreview {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Перенести событие?")
                            .font(.headline)

                        Text("📌 \(event.title)")
                        Text("📅 \(event.date)")
                        Text("🕒 \(event.time)")
                        Text("🔔 \(event.reminder)")

                        HStack {
                            Button("Отмена") {
                                viewModel.cancelMoveEvent()
                            }
                            .buttonStyle(.bordered)

                            Spacer()

                            Button("Перенести") {
                                Task {
                                    await viewModel.confirmMoveEvent()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button {
                                Task {
                                    await viewModel.prepareMoveEvent()
                                }
                            } label: {
                                Text("Перенести событие голосом")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.isProcessing || !viewModel.hasCalendarAccess)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                if let event = viewModel.reminderUpdatePreview {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Изменить напоминание?")
                            .font(.headline)

                        Text("📌 \(event.title)")
                        Text("📅 \(event.date)")
                        Text("🕒 \(event.time)")
                        Text("🔔 \(event.reminder)")

                        HStack {
                            Button("Отмена") {
                                viewModel.cancelReminderUpdate()
                            }
                            .buttonStyle(.bordered)

                            Spacer()

                            Button("Изменить") {
                                Task {
                                    await viewModel.confirmReminderUpdate()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button {
                                Task {
                                    await viewModel.prepareReminderUpdate()
                                }
                            } label: {
                                Text("Изменить напоминание голосом")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(viewModel.isProcessing || !viewModel.hasCalendarAccess)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

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
