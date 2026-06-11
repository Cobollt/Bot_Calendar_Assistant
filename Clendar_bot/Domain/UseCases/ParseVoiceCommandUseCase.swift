final class ParseVoiceCommandUseCase{
    private let commandParser: CommandParserProtocol
    
    init(commandParser: CommandParserProtocol) {
        self.commandParser = commandParser
    }
    
    func execute(_ command: VoiceCommand) throws -> CalendarEvent {
        try commandParser.parce(command)
    }
}
