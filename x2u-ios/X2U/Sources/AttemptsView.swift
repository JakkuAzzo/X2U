import SwiftUI

struct AttemptsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedReview: QuizReviewPayload?
    @State private var isLoadingReview = false

    var body: some View {
        NavigationStack {
            if appState.quizHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(X2UTheme.slate)

                    Text("No Quiz Attempts Yet")
                        .font(.headline)
                        .foregroundStyle(X2UTheme.ink)

                    Text("Complete quizzes to see your history and review answers here.")
                        .foregroundStyle(X2UTheme.slate)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(X2UTheme.pageBackground)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(appState.quizHistory.sorted { $0.completedAt > $1.completedAt }) { attempt in
                            attemptCard(attempt)
                        }
                    }
                    .padding(20)
                }
                .background(X2UTheme.pageBackground)
            }

            .navigationTitle("Quiz Attempts")
            .navigationBarTitleDisplayMode(.inline)
            .x2uScreenBackground()
        }
        .sheet(item: Binding(
            get: { selectedReview },
            set: { selectedReview = $0 }
        )) { review in
            QuizReviewDetailsView(review: review)
        }
    }

    private func attemptCard(_ attempt: QuizHistoryItem) -> some View {
        NavigationLink(value: attempt.sessionId) {
            CardView {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Session #\(attempt.sessionId)")
                                .font(.headline)
                                .foregroundStyle(X2UTheme.ink)

                            Text(formatDate(attempt.completedAt))
                                .font(.caption)
                                .foregroundStyle(X2UTheme.slate)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(Int(attempt.totalScore.rounded()))%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(attempt.passed ? X2UTheme.accent : .red)

                            Text(attempt.passed ? "Passed" : "Failed")
                                .font(.caption)
                                .foregroundStyle(attempt.passed ? X2UTheme.accent : .red)
                        }
                    }

                    Divider()

                    HStack {
                        Label("\(attempt.questionCount) questions", systemImage: "list.bullet")
                            .font(.caption)
                            .foregroundStyle(X2UTheme.slate)

                        Spacer()

                        Label(attempt.sessionType, systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(X2UTheme.slate)
                    }

                    Button("Review Answers") {
                        loadReview(attempt.sessionId)
                    }
                    .buttonStyle(.bordered)
                    .tint(X2UTheme.accent)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func loadReview(_ sessionId: Int) {
        isLoadingReview = true
        Task {
            selectedReview = await appState.getQuizReview(sessionId: sessionId)
            isLoadingReview = false
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct QuizReviewDetailsView: View {
    let review: QuizReviewPayload
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    CardView {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Session #\(review.sessionId)")
                                    .font(.headline)
                                    .foregroundStyle(X2UTheme.ink)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("\(Int(review.totalScore.rounded()))%")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(review.passed ? X2UTheme.accent : .red)

                                    Text(review.passed ? "Passed" : "Failed")
                                        .font(.caption)
                                        .foregroundStyle(review.passed ? X2UTheme.accent : .red)
                                }
                            }

                            Divider()

                            HStack {
                                Text(review.sessionType.capitalized)
                                    .font(.caption)
                                    .foregroundStyle(X2UTheme.slate)

                                Spacer()

                                Text(formatDate(review.completedAt))
                                    .font(.caption)
                                    .foregroundStyle(X2UTheme.slate)
                            }
                        }
                    }

                    ForEach(review.questions) { question in
                        questionReviewCard(question)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Review Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .x2uScreenBackground()
        }
    }

    private func questionReviewCard(_ question: QuizReviewQuestion) -> some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(question.questionText)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(X2UTheme.ink)

                        if question.isCorrect {
                            Label("Correct", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        } else {
                            Label("Incorrect", systemImage: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }

                    Spacer()
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Answer:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(X2UTheme.slate)

                    Text(question.selectedOptionText)
                        .font(.caption)
                        .foregroundStyle(question.isCorrect ? .green : .red)
                        .padding(8)
                        .background(question.isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .cornerRadius(4)

                    if !question.isCorrect {
                        Text("Correct Answer:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(X2UTheme.slate)

                        Text(question.correctOptionText)
                            .font(.caption)
                            .foregroundStyle(.green)
                            .padding(8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}
