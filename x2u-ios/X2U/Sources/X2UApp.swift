import SwiftUI

@main
struct X2UApp: App {
    @StateObject private var appState = AppState()
    @State private var didRestoreSession = false
    @State private var isBootstrapping = true

    var body: some Scene {
        WindowGroup {
            Group {
                if isBootstrapping {
                    SplashGateView()
                } else if appState.isConnected {
                    RootTabView()
                } else {
                    LoginView()
                }
            }
                .environmentObject(appState)
                .task {
                    guard !didRestoreSession else { return }
                    didRestoreSession = true
                    await appState.restoreSession()
                    isBootstrapping = false
                }
        }
    }
}

private struct SplashGateView: View {
    var body: some View {
        ZStack {
            X2UTheme.pageBackground
                .ignoresSafeArea()

            VStack(spacing: 14) {
                X2ULogoView(size: 92)
                    .shadow(color: .black.opacity(0.15), radius: 14, x: 0, y: 6)
                Text("X2U")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(X2UTheme.ink)
                SwiftUI.ProgressView()
                    .tint(X2UTheme.accent)
            }
        }
    }
}
