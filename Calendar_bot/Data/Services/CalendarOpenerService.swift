import UIKit

final class CalendarOpenerService: CalendarOpenerProtocol {

    func openCalendar() {
        guard let url = URL(string: "calshow://") else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
