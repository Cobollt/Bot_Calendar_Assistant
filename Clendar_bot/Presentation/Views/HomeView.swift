import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {

            Text("Calendar Assistant")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 8) {
                Text("Распознанная команда:")
                    .font(.headline)

                Text(viewModel.recognizedText.isEmpty
                     ? "Команда пока не получена"
                     : viewModel.recognizedText)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Text(viewModel.statusMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if viewModel.isProcessing {
                ProgressView()
            }

            VStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.requestCalendarAccess()
                    }
                } label: {
                    Text("Разрешить доступ к календарю")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    Task {
                        await viewModel.processVoiceCommand()
                    }
                } label: {
                    Text(viewModel.isProcessing
                         ? "Обработка..."
                         : "Добавить событие")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isProcessing)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    let container = AppContainer()

    HomeView(
        viewModel: container.makeHomeViewModel()
    )
}
