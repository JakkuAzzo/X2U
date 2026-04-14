import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            CoursesView()
                .tabItem {
                    Label("Learning", systemImage: "books.vertical")
                }

            CoursesLibraryView()
                .tabItem {
                    Label("Driving", systemImage: "car")
                }

            AttemptsView()
                .tabItem {
                    Label("Attempts", systemImage: "checkmark.circle")
                }

            LearningProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .tint(X2UTheme.accent)
        .background(X2UTheme.pageBackground)
    }
}
