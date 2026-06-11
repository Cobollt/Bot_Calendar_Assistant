import Foundation


protocol CommandParserProtocol {
    func parce(_ command: VoiceCommand) throws -> CalendarEvent
}
