import SwiftUI

@main
struct X2UApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
                .task {
                    await appState.ensureConnected()
                }
        }
    }
}
