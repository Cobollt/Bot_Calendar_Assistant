import SwiftUI

@main
struct CalendarBotApp: App {

    private let container = AppContainer()

    var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: container.makeHomeViewModel()
            )
        }
    }
}
