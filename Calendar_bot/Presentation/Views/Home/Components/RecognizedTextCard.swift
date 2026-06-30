import SwiftUI

struct RecognizedTextCard: View {

    let text: String

    var body: some View {
        Text(
            text.isEmpty
            ? "Команда пока не получена"
            : text
        )
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
