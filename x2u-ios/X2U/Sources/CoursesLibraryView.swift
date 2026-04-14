import SwiftUI

struct CoursesLibraryView: View {
    @EnvironmentObject private var appState: AppState
    let onSwitchCourse: () -> Void

    var body: some View {
        content
            .background(X2UTheme.pageBackground)
    }

    @ViewBuilder
    private var content: some View {
        if appState.drivingTheoryCourses.isEmpty {
            VStack(spacing: 16) {
                topBar

                Image(systemName: "book")
                    .font(.system(size: 48))
                    .foregroundStyle(X2UTheme.slate)

                Text("No Courses Available")
                    .font(.headline)
                    .foregroundStyle(X2UTheme.ink)

                Text("Check your connection and try refreshing.")
                    .foregroundStyle(X2UTheme.slate)
                    .multilineTextAlignment(.center)

                Button("Refresh") {
                    Task { await appState.refreshRemoteState() }
                }
                .buttonStyle(.bordered)
                .tint(X2UTheme.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    topBar

                    ForEach(appState.drivingTheoryCourses) { course in
                        courseCard(course)
                    }
                }
            }
            .padding(20)
        }
    }

    private var topBar: some View {
        HStack {
            Button("Switch Course") {
                onSwitchCourse()
            }
            .buttonStyle(.bordered)
            .tint(X2UTheme.accent)

            Spacer()

            Image(systemName: "car")
                .foregroundStyle(X2UTheme.accent)
        }
    }

    private func courseCard(_ course: DrivingTheoryCourse) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(course.title)
                            .font(.headline)
                            .foregroundStyle(X2UTheme.ink)

                        Text(course.description)
                            .font(.caption)
                            .foregroundStyle(X2UTheme.slate)
                            .lineLimit(2)
                    }

                    Spacer()

                    if appState.isSubscribedToCourse(course) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(X2UTheme.accent)
                    }
                }

                Divider()

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Questions")
                            .font(.caption)
                            .foregroundStyle(X2UTheme.slate)
                        Text("\(course.totalQuestions)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(X2UTheme.ink)
                    }

                    Divider()
                        .frame(height: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Duration")
                            .font(.caption)
                            .foregroundStyle(X2UTheme.slate)
                        Text("\(course.durationMinutes)min")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(X2UTheme.ink)
                    }

                    Divider()
                        .frame(height: 36)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pass Score")
                            .font(.caption)
                            .foregroundStyle(X2UTheme.slate)
                        Text("\(Int(course.passingScore))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(X2UTheme.ink)
                    }

                    Spacer()
                }

                Button(action: {
                    Task {
                        if appState.isSubscribedToCourse(course) {
                            await appState.unsubscribeFromCourse(course)
                        } else {
                            await appState.subscribeToCourse(course)
                        }
                    }
                }) {
                    Text(appState.isSubscribedToCourse(course) ? "Unsubscribe" : "Subscribe")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(appState.isSubscribedToCourse(course) ? .gray : X2UTheme.accent)
            }
        }
    }
}
