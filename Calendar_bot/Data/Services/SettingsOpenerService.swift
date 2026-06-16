import UIKit

final class SettingsOpenerService:
SettingsOpenerProtocol {

    func openSettings() {

        guard let url =
        URL(
            string:
            UIApplication.openSettingsURLString
        )

        else {

            return

        }

        UIApplication.shared.open(url)
    }
}
