import SwiftUI

struct QuizSessionView: View {
    @EnvironmentObject private var appState: AppState

    let course: Course
    let quiz: CourseQuiz

    @State private var selectedIndexByQuestion: [UUID: Int] = [:]
    @State private var submitted = false
    @State private var score = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CardView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(quiz.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(X2UTheme.ink)

                        Text("Answer all questions and submit to record progress.")
                            .foregroundStyle(X2UTheme.slate)
                    }
                }

                ForEach(quiz.questions) { question in
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(question.prompt)
                                .font(.headline)
                                .foregroundStyle(X2UTheme.ink)

                            ForEach(Array(question.options.enumerated()), id: \.offset) { idx, option in
                                optionRow(question: question, index: idx, option: option)
                            }
                        }
                    }
                }

                Button(action: submitQuiz) {
                    Text(submitted ? "Retake Quiz" : "Submit Quiz")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(X2UTheme.accent)

                if submitted {
                    CardView {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Result")
                                .font(.headline)
                                .foregroundStyle(X2UTheme.ink)
                            Text("You scored \(score) / \(quiz.questions.count)")
                                .foregroundStyle(X2UTheme.slate)
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .x2uScreenBackground()
    }

    private func optionRow(question: QuizQuestion, index: Int, option: String) -> some View {
        Button {
            guard !submitted else { return }
            selectedIndexByQuestion[question.id] = index
        } label: {
            HStack {
                Image(systemName: selectedIndexByQuestion[question.id] == index ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(X2UTheme.accent)
                Text(option)
                    .foregroundStyle(X2UTheme.ink)
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private func submitQuiz() {
        if submitted {
            selectedIndexByQuestion = [:]
            submitted = false
            score = 0
            return
        }

        score = quiz.questions.reduce(into: 0) { current, question in
            if selectedIndexByQuestion[question.id] == question.correctIndex {
                current += 1
            }
        }

        submitted = true
        appState.submitQuiz(courseID: course.id, quizID: quiz.id, score: score, total: quiz.questions.count)
    }
}
