import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    hero

                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(appState.isConnected ? "Connected to X2U API" : "Not Connected")
                                    .font(.headline)
                                    .foregroundStyle(X2UTheme.ink)
                                Spacer()
                                if appState.isSyncing {
                                    SwiftUI.ProgressView()
                                        .tint(X2UTheme.accent)
                                }
                            }

                            if let email = appState.profileEmail {
                                Text(email)
                                    .font(.caption)
                                    .foregroundStyle(X2UTheme.slate)
                            }

                            if let error = appState.syncError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }

                            Button("Refresh Live Data") {
                                Task { await appState.refreshRemoteState() }
                            }
                            .buttonStyle(.bordered)
                            .tint(X2UTheme.accent)
                        }
                    }

                    CardView {
                        HStack {
                            metric(title: "Subscribed", value: "\(appState.subscribedCourses.count)")
                            Spacer()
                            metric(title: "Average Score", value: appState.averageScoreText)
                        }
                    }

                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Active Learning Areas")
                                .font(.headline)
                                .foregroundStyle(X2UTheme.ink)

                            if appState.subscribedCourses.isEmpty {
                                Text("Subscribe to at least one course to personalize your learning track.")
                                    .foregroundStyle(X2UTheme.slate)
                            } else {
                                ForEach(appState.subscribedCourses.prefix(3)) { course in
                                    HStack {
                                        Image(systemName: course.domain.symbol)
                                        Text(course.title)
                                        Spacer()
                                        Text("\(Int(appState.completionRatio(for: course) * 100))%")
                                            .foregroundStyle(X2UTheme.slate)
                                    }
                                    .foregroundStyle(X2UTheme.ink)
                                }
                            }
                        }
                    }

                    CardView {
                        HStack {
                            metric(title: "Completed Quizzes", value: "\(appState.progressSnapshot.totalQuizzesCompleted)")
                            Spacer()
                            metric(title: "Improvement", value: "\(Int(appState.progressSnapshot.improvementPercentage.rounded()))%")
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("X2U")
            .x2uScreenBackground()
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            X2ULogoView(size: 84)
                .shadow(color: .black.opacity(0.14), radius: 14, x: 0, y: 6)

            Text("Personalized Learning")
                .font(.caption)
                .fontWeight(.semibold)
                .textCase(.uppercase)
                .opacity(0.9)

            Text("Learn, quiz, and track progress across multiple domains.")
                .font(.title3)
                .fontWeight(.bold)

            Text("Inspired by X2U, expanded for broader learning and testing.")
                .font(.subheadline)
                .opacity(0.92)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(X2UTheme.heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(X2UTheme.slate)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(X2UTheme.ink)
        }
    }
}
