import Foundation

enum ParserError: Error {
    case emptyCommand
    case invalidDate
    case invalidTime
    case emptyTitle
}
