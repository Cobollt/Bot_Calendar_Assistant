final class RequestCalendarAccessUseCase {
    private let calendarRepository: CalendarRepositoryProtocol
    
    init(calendarRepository: CalendarRepositoryProtocol) {
        self.calendarRepository = calendarRepository
    }
    
    func execute() async throws -> Bool {
        try await calendarRepository.requestAccess()
    }
}
