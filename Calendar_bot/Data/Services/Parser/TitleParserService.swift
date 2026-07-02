import Foundation

final class TitleParserService {

    private let titleBuilder: EventTitleBuilderService

    init(titleBuilder: EventTitleBuilderService) {
        self.titleBuilder = titleBuilder
    }

    func extractTitle(from text: String) -> String {
        titleBuilder.buildTitle(from: text)
    }
}
