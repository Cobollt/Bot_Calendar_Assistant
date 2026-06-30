import SwiftUI

struct AccessWarningView: View {

    var body: some View {
        Text("Доступ к календарю нужно выдать в настройках.")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
}
