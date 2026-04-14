import XCTest
@testable import X2U

@MainActor
final class X2UTests: XCTestCase {
    private func makeState() -> AppState {
        let suiteName = "x2u.tests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return AppState(courses: SeedData.courses, storage: defaults, stateKey: "state")
    }

    func testToggleSubscription() {
        let state = makeState()
        let course = SeedData.courses[0]

        XCTAssertFalse(state.isSubscribed(course))
        state.toggleSubscription(for: course)
        XCTAssertTrue(state.isSubscribed(course))
        state.toggleSubscription(for: course)
        XCTAssertFalse(state.isSubscribed(course))
    }

    func testSubmitQuizUpdatesProgress() {
        let state = makeState()
        let course = SeedData.courses[0]
        let quiz = course.quizzes[0]

        state.submitQuiz(courseID: course.id, quizID: quiz.id, score: 2, total: 3)

        let progress = state.progress(for: course)
        XCTAssertTrue(progress.completedQuizIDs.contains(quiz.id))
        XCTAssertEqual(progress.attempts.count, 1)
        XCTAssertEqual(progress.attempts.first?.score, 2)
        XCTAssertEqual(progress.attempts.first?.total, 3)
        XCTAssertEqual(state.completionRatio(for: course), 1)
    }
}
