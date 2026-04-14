import SwiftUI

struct CourseDetailView: View {
    @EnvironmentObject private var appState: AppState
    let course: Course

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CardView {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(course.title, systemImage: course.domain.symbol)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(X2UTheme.ink)

                        Text(course.summary)
                            .foregroundStyle(X2UTheme.slate)

                        Button(action: { appState.toggleSubscription(for: course) }) {
                            Text(appState.isSubscribed(course) ? "Unsubscribe" : "Subscribe")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(X2UTheme.accent)
                    }
                }

                CardView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Live X2U Quizzes")
                            .font(.headline)
                            .foregroundStyle(X2UTheme.ink)

                        if let weekly = appState.weeklyQuiz {
                            NavigationLink {
                                LiveQuizSessionView(title: "Weekly Live Quiz", session: weekly)
                            } label: {
                                liveQuizRow(title: "Weekly Live Quiz", questionCount: weekly.questions.count)
                            }
                            .buttonStyle(.plain)
                        }

                        if let monthly = appState.monthlyQuiz {
                            NavigationLink {
                                LiveQuizSessionView(title: "Monthly Live Quiz", session: monthly)
                            } label: {
                                liveQuizRow(title: "Monthly Live Quiz", questionCount: monthly.questions.count)
                            }
                            .buttonStyle(.plain)
                        }

                        if appState.weeklyQuiz == nil && appState.monthlyQuiz == nil {
                            Text("No live sessions loaded yet.")
                                .font(.caption)
                                .foregroundStyle(X2UTheme.slate)

                            Button("Load Live Quizzes") {
                                Task { await appState.refreshRemoteState() }
                            }
                            .buttonStyle(.bordered)
                            .tint(X2UTheme.accent)
                        }
                    }
                }

                ForEach(course.quizzes) { quiz in
                    NavigationLink {
                        QuizSessionView(course: course, quiz: quiz)
                    } label: {
                        CardView {
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(quiz.title)
                                        .font(.headline)
                                        .foregroundStyle(X2UTheme.ink)
                                    Text("\(quiz.questions.count) questions")
                                        .font(.caption)
                                        .foregroundStyle(X2UTheme.slate)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(X2UTheme.slate)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .navigationTitle("Course")
        .navigationBarTitleDisplayMode(.inline)
        .x2uScreenBackground()
    }

    private func liveQuizRow(title: String, questionCount: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(X2UTheme.ink)
                Text("\(questionCount) questions from backend")
                    .font(.caption)
                    .foregroundStyle(X2UTheme.slate)
            }
            Spacer()
            Image(systemName: "bolt.shield")
                .foregroundStyle(X2UTheme.accent)
        }
    }
}
