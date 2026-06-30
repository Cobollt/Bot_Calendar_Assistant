import SwiftUI

struct EventActionPreviewCard: View {

    let action: HomePendingAction
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        if let event = action.preview {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline)

                Text("📌 \(event.title)")
                Text("📅 \(event.date)")
                Text("🕒 \(event.time)")
                Text("🔔 \(event.reminder)")
                Text("🔁 \(event.recurrence)")

                HStack {
                    Button("Отмена") {
                        onCancel()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button(confirmTitle) {
                        onConfirm()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(confirmTint)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var title: String {
        switch action {
        case .none:
            return ""
        case .create:
            return "Создать это событие?"
        case .delete:
            return "Удалить это событие?"
        case .move:
            return "Перенести событие?"
        case .updateReminder:
            return "Изменить напоминание?"
        }
    }

    private var confirmTitle: String {
        switch action {
        case .none:
            return ""
        case .create:
            return "Создать"
        case .delete:
            return "Удалить"
        case .move:
            return "Перенести"
        case .updateReminder:
            return "Изменить"
        }
    }

    private var confirmTint: Color {
        switch action {
        case .delete:
            return .red
        default:
            return .accentColor
        }
    }

    private var backgroundColor: Color {
        switch action {
        case .none:
            return Color.clear
        case .create:
            return Color.gray.opacity(0.12)
        case .delete:
            return Color.red.opacity(0.10)
        case .move:
            return Color.blue.opacity(0.10)
        case .updateReminder:
            return Color.orange.opacity(0.10)
        }
    }
}
