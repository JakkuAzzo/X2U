import SwiftUI

struct LearningProgressView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if appState.subscribedCourses.isEmpty {
                        CardView {
                            Text("Subscribe to a course to start tracking progress.")
                                .foregroundStyle(X2UTheme.slate)
                        }
                    }

                    CardView {
                        HStack {
                            metric(title: "Completed", value: "\(appState.progressSnapshot.totalQuizzesCompleted)")
                            Spacer()
                            metric(title: "Average", value: "\(Int(appState.progressSnapshot.averageScore.rounded()))%")
                            Spacer()
                            metric(title: "Improvement", value: "\(Int(appState.progressSnapshot.improvementPercentage.rounded()))%")
                        }
                    }

                    if !appState.progressSnapshot.topicScores.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Topic Mastery")
                                    .font(.headline)
                                    .foregroundStyle(X2UTheme.ink)

                                ForEach(appState.progressSnapshot.topicScores.keys.sorted(), id: \.self) { topic in
                                    let rawValue = appState.progressSnapshot.topicScores[topic] ?? 0
                                    let normalized = rawValue > 1 ? rawValue / 100.0 : rawValue

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(topic.replacingOccurrences(of: "_", with: " ").capitalized)
                                                .font(.caption)
                                                .foregroundStyle(X2UTheme.ink)
                                            Spacer()
                                            Text("\(Int((normalized * 100).rounded()))%")
                                                .font(.caption)
                                                .foregroundStyle(X2UTheme.slate)
                                        }

                                        SwiftUI.ProgressView(value: max(0, min(1, normalized)))
                                            .tint(X2UTheme.accent)
                                    }
                                }
                            }
                        }
                    }

                    if !appState.topicHistory.isEmpty {
                        CardView {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Recent Sessions")
                                    .font(.headline)
                                    .foregroundStyle(X2UTheme.ink)

                                ForEach(appState.topicHistory.suffix(3).reversed()) { item in
                                    HStack {
                                        Text("Session #\(item.sessionId)")
                                            .font(.caption)
                                        Spacer()
                                        Text("\(Int(item.totalScore.rounded()))%")
                                            .font(.caption)
                                            .foregroundStyle(X2UTheme.slate)
                                    }
                                    .foregroundStyle(X2UTheme.ink)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Progress")
            .x2uScreenBackground()
        }
    }

    private func metric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(X2UTheme.slate)
            Text(value)
                .font(.headline)
                .foregroundStyle(X2UTheme.ink)
        }
    }
}
