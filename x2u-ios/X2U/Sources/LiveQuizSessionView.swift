import SwiftUI

struct LiveQuizSessionView: View {
    @EnvironmentObject private var appState: AppState

    let title: String
    let session: BackendQuizSession

    @State private var selectedOptionByQuestionID: [Int: Int] = [:]
    @State private var result: BackendQuizSubmissionResponse?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CardView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(X2UTheme.ink)

                        Text("Submit answers to sync quiz attempts and progress with Cyber2U.")
                            .foregroundStyle(X2UTheme.slate)
                    }
                }

                ForEach(session.questions) { question in
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(question.questionText)
                                .font(.headline)
                                .foregroundStyle(X2UTheme.ink)

                            ForEach(question.options) { option in
                                optionRow(questionID: question.id, option: option)
                            }
                        }
                    }
                }

                Button("Submit to Cyber2U") {
                    Task {
                        result = await appState.submitLiveQuiz(sessionId: session.sessionId, answers: selectedOptionByQuestionID)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(X2UTheme.accent)
                .disabled(selectedOptionByQuestionID.isEmpty || appState.isSyncing)

                if let result {
                    CardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(result.passed ? "Passed" : "Completed")
                                .font(.headline)
                                .foregroundStyle(X2UTheme.ink)

                            Text("Score: \(Int(result.score.rounded()))%")
                                .foregroundStyle(X2UTheme.slate)

                            Text("Correct: \(result.correctAnswers)/\(result.totalQuestions)")
                                .foregroundStyle(X2UTheme.slate)
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Live Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .x2uScreenBackground()
    }

    private func optionRow(questionID: Int, option: BackendQuizOption) -> some View {
        Button {
            selectedOptionByQuestionID[questionID] = option.id
        } label: {
            HStack {
                Image(systemName: selectedOptionByQuestionID[questionID] == option.id ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(X2UTheme.accent)
                Text(option.optionText)
                    .foregroundStyle(X2UTheme.ink)
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
