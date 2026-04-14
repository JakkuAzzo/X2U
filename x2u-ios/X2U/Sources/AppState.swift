import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var profileEmail: String?
    @Published private(set) var isConnected: Bool
    @Published private(set) var isSyncing: Bool
    @Published private(set) var syncError: String?

    @Published private(set) var progressSnapshot: BackendProgressSnapshot
    @Published private(set) var topicHistory: [TopicHistoryPoint]
    @Published private(set) var weeklyQuiz: BackendQuizSession?
    @Published private(set) var monthlyQuiz: BackendQuizSession?

    @Published private(set) var courses: [Course]
    @Published private(set) var subscribedCourseIDs: Set<UUID>
    @Published private(set) var courseProgressByID: [UUID: CourseProgress]
    @Published private(set) var drivingTheoryCourses: [DrivingTheoryCourse]
    @Published private(set) var drivingTheorySubscribedCourseIDs: Set<Int>
    @Published private(set) var quizHistory: [QuizHistoryItem]
    @Published private(set) var apiBaseURL: String
    @Published private(set) var authMethod: AuthMethod

    enum AuthMethod: String, Codable {
        case demoBootstrap = "demo_bootstrap"
        case magicLink = "magic_link"
    }

    private let storage: UserDefaults
    private let tokenKey: String
    private let stateKey: String
    private let api: APIClient

    private struct LocalState: Codable {
        var subscribedCourseIDs: Set<UUID>
        var courseProgressByID: [UUID: CourseProgress]
    }

    init(
        courses: [Course] = SeedData.courses,
        storage: UserDefaults = .standard,
        stateKey: String = "x2u.course.state.v1",
        tokenKey: String = "x2u.auth.token.v1",
        api: APIClient = .shared
    ) {
        self.profileEmail = nil
        self.isConnected = false
        self.isSyncing = false
        self.syncError = nil

        self.progressSnapshot = .empty
        self.topicHistory = []
        self.weeklyQuiz = nil
        self.monthlyQuiz = nil

        self.courses = courses
        self.subscribedCourseIDs = []
        self.courseProgressByID = [:]
        self.drivingTheoryCourses = []
        self.drivingTheorySubscribedCourseIDs = []
        self.quizHistory = []
        self.apiBaseURL = storage.string(forKey: "x2u.api.baseURL") ?? "http://localhost:3000/api"
        self.authMethod = AuthMethod(rawValue: storage.string(forKey: "x2u.auth.method") ?? "demo_bootstrap") ?? .demoBootstrap

        self.storage = storage
        self.tokenKey = tokenKey
        self.stateKey = stateKey
        self.api = api

        restoreLocalState()

        isConnected = authToken != nil
    }

    var subscribedCourses: [Course] {
        courses.filter { subscribedCourseIDs.contains($0.id) }
    }

    var averageScoreText: String {
        let attempts = courseProgressByID.values.flatMap { $0.attempts }
        guard !attempts.isEmpty else { return "0%" }

        let averageRatio = attempts.reduce(0.0) { runningTotal, attempt in
            runningTotal + (Double(attempt.score) / Double(max(attempt.total, 1)))
        } / Double(attempts.count)

        return "\(Int((averageRatio * 100).rounded()))%"
    }

    func connectDemoUser(email: String?) async {
        setSyncing(true)
        defer { setSyncing(false) }

        do {
            let response = try await api.bootstrapDemoUser(email: email)
            authToken = response.token
            profileEmail = response.email
            isConnected = true
            syncError = nil
            await refreshRemoteState()
        } catch {
            syncError = error.localizedDescription
            isConnected = false
        }
    }

    func ensureConnected() async {
        if authToken == nil {
            await connectDemoUser(email: nil)
            return
        }

        await refreshRemoteState()
    }

    func refreshRemoteState() async {
        guard let token = authToken else {
            syncError = "No auth token found."
            return
        }

        setSyncing(true)
        defer { setSyncing(false) }

        do {
            async let profileData = api.getProfile(token: token)
            async let progressData = api.getProgress(token: token)
            async let topicHistoryData = api.getTopicHistory(token: token)
            async let weeklyQuizData = api.getWeeklyQuiz(token: token)
            async let monthlyQuizData = api.getMonthlyQuiz(token: token)
            async let coursesData = api.listCourses()
            async let historyData = api.getQuizHistory(token: token)

            let profile = try await profileData
            let progress = try await progressData
            let history = try await topicHistoryData
            let weekly = try await weeklyQuizData
            let monthly = try await monthlyQuizData
            let coursesResponse = try await coursesData
            let quizHist = try await historyData

            profileEmail = profile.email
            progressSnapshot = progress
            topicHistory = history.history
            weeklyQuiz = weekly
            monthlyQuiz = monthly
            drivingTheoryCourses = coursesResponse.courses
            quizHistory = quizHist.sessions

            syncError = nil
            isConnected = true
        } catch {
            syncError = error.localizedDescription
        }
    }

    func submitLiveQuiz(sessionId: Int, answers: [Int: Int]) async -> BackendQuizSubmissionResponse? {
        guard let token = authToken else {
            syncError = "Connect a demo user first."
            return nil
        }

        setSyncing(true)
        defer { setSyncing(false) }

        do {
            let response = try await api.submitQuizAnswers(sessionId: sessionId, answers: answers, token: token)
            progressSnapshot = response.progress
            syncError = nil
            await refreshQuizzesOnly(token: token)
            await refreshTopicHistoryOnly(token: token)
            return response
        } catch {
            syncError = error.localizedDescription
            return nil
        }
    }

    func toggleSubscription(for course: Course) {
        if subscribedCourseIDs.contains(course.id) {
            subscribedCourseIDs.remove(course.id)
        } else {
            subscribedCourseIDs.insert(course.id)
        }

        persistLocalState()
    }

    func isSubscribed(_ course: Course) -> Bool {
        subscribedCourseIDs.contains(course.id)
    }

    func progress(for course: Course) -> CourseProgress {
        courseProgressByID[course.id] ?? .empty
    }

    func completionRatio(for course: Course) -> Double {
        let progress = progress(for: course)
        return Double(progress.completedQuizIDs.count) / Double(max(course.quizzes.count, 1))
    }

    func submitQuiz(courseID: UUID, quizID: UUID, score: Int, total: Int) {
        var progress = courseProgressByID[courseID] ?? .empty
        progress.completedQuizIDs.insert(quizID)
        progress.attempts.append(
            QuizAttempt(
                quizID: quizID,
                score: score,
                total: total,
                completedAt: Date()
            )
        )
        courseProgressByID[courseID] = progress
        persistLocalState()
    }

    func setAPIBaseURL(_ url: String) {
        apiBaseURL = url
        storage.set(url, forKey: "x2u.api.baseURL")
    }

    func setAuthMethod(_ method: AuthMethod) {
        authMethod = method
        storage.set(method.rawValue, forKey: "x2u.auth.method")
    }

    func subscribeToCourse(_ course: DrivingTheoryCourse) async {
        guard let token = authToken else {
            syncError = "Not connected."
            return
        }

        setSyncing(true)
        defer { setSyncing(false) }

        do {
            _ = try await api.subscribeToCourse(courseId: course.id, token: token)
            drivingTheorySubscribedCourseIDs.insert(course.id)
            syncError = nil
        } catch {
            syncError = error.localizedDescription
        }
    }

    func unsubscribeFromCourse(_ course: DrivingTheoryCourse) async {
        guard let token = authToken else {
            syncError = "Not connected."
            return
        }

        setSyncing(true)
        defer { setSyncing(false) }

        do {
            _ = try await api.unsubscribeFromCourse(courseId: course.id, token: token)
            drivingTheorySubscribedCourseIDs.remove(course.id)
            syncError = nil
        } catch {
            syncError = error.localizedDescription
        }
    }

    func isSubscribedToCourse(_ course: DrivingTheoryCourse) -> Bool {
        drivingTheorySubscribedCourseIDs.contains(course.id)
    }

    func getQuizReview(sessionId: Int) async -> QuizReviewPayload? {
        guard let token = authToken else { return nil }

        setSyncing(true)
        defer { setSyncing(false) }

        do {
            return try await api.getQuizReview(sessionId: sessionId, token: token)
        } catch {
            syncError = error.localizedDescription
            return nil
        }
    }

    private func refreshQuizzesOnly(token: String) async {
        async let weekly = api.getWeeklyQuiz(token: token)
        async let monthly = api.getMonthlyQuiz(token: token)

        do {
            weeklyQuiz = try await weekly
            monthlyQuiz = try await monthly
        } catch {
            syncError = error.localizedDescription
        }
    }

    private func refreshTopicHistoryOnly(token: String) async {
        do {
            topicHistory = try await api.getTopicHistory(token: token).history
        } catch {
            syncError = error.localizedDescription
        }
    }

    private func restoreLocalState() {
        guard let data = storage.data(forKey: stateKey),
              let decoded = try? JSONDecoder().decode(LocalState.self, from: data) else {
            return
        }

        subscribedCourseIDs = decoded.subscribedCourseIDs
        courseProgressByID = decoded.courseProgressByID
    }

    private func persistLocalState() {
        let state = LocalState(
            subscribedCourseIDs: subscribedCourseIDs,
            courseProgressByID: courseProgressByID
        )

        guard let data = try? JSONEncoder().encode(state) else { return }
        storage.set(data, forKey: stateKey)
    }

    private var authToken: String? {
        get { storage.string(forKey: tokenKey) }
        set {
            if let value = newValue {
                storage.set(value, forKey: tokenKey)
            } else {
                storage.removeObject(forKey: tokenKey)
            }
        }
    }

    private func setSyncing(_ isSyncing: Bool) {
        self.isSyncing = isSyncing
    }
}
