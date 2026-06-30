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
            ScrollView {
                VStack(spacing: 24) {
                    Text("Calendar Assistant")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    RecognizedTextCard(
                        text: viewModel.recognizedText
                    )

                    EventActionPreviewCard(
                        action: viewModel.pendingAction,
                        onCancel: {
                            viewModel.cancelPendingAction()
                        },
                        onConfirm: {
                            Task {
                                await viewModel.confirmPendingAction()
                            }
                        }
                    )

                    Text(viewModel.statusMessage)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    if viewModel.isProcessing {
                        ProgressView()
                    }

                    HomeActionButtonsView(
                        isProcessing: viewModel.isProcessing,
                        hasCalendarAccess: viewModel.hasCalendarAccess,
                        onCreate: {
                            Task {
                                await viewModel.prepareCreateEvent()
                            }
                        },
                        onDelete: {
                            Task {
                                await viewModel.prepareDeleteEvent()
                            }
                        },
                        onMove: {
                            Task {
                                await viewModel.prepareMoveEvent()
                            }
                        },
                        onReminderUpdate: {
                            Task {
                                await viewModel.prepareReminderUpdate()
                            }
                        },
                        onOpenCalendar: {
                            viewModel.openCalendar()
                        }
                    )

                    if !viewModel.hasCalendarAccess {
                        AccessWarningView()
                    }
                }
                .padding()
            }
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
