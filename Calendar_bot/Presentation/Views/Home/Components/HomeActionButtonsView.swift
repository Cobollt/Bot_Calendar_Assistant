import SwiftUI

struct HomeActionButtonsView: View {

    let isProcessing: Bool
    let hasCalendarAccess: Bool

    let onCreate: () -> Void
    let onDelete: () -> Void
    let onMove: () -> Void
    let onReminderUpdate: () -> Void
    let onOpenCalendar: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button {
                onCreate()
            } label: {
                Text(isProcessing ? "Слушаю..." : "Создать событие голосом")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isDisabled)

            Button {
                onDelete()
            } label: {
                Text("Удалить событие голосом")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isDisabled)

            Button {
                onMove()
            } label: {
                Text("Перенести событие голосом")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isDisabled)

            Button {
                onReminderUpdate()
            } label: {
                Text("Изменить напоминание голосом")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(isDisabled)

            Button {
                onOpenCalendar()
            } label: {
                Text("Открыть календарь")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }

    private var isDisabled: Bool {
        isProcessing || !hasCalendarAccess
    }
}
