import Foundation

final class OpenCalendarUseCase {

    private let calendarOpener: CalendarOpenerProtocol

    init(calendarOpener: CalendarOpenerProtocol) {
        self.calendarOpener = calendarOpener
    }

    func execute() {
        calendarOpener.openCalendar()
    }
}
