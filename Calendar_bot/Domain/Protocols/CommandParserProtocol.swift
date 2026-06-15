import Foundation


protocol CommandParserProtocol {
    func parse(_ command: VoiceCommand) throws -> CalendarEvent
}
