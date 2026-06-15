final class CheckCalendarAccessUseCase {

    private let calendarRepository: CalendarRepositoryProtocol

    init(calendarRepository: CalendarRepositoryProtocol) {
        self.calendarRepository = calendarRepository
    }

    func execute() -> Bool {
        calendarRepository.hasCalendarAccess()
    }
}
