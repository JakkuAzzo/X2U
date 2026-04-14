import Foundation

enum APIClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case server(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API base URL."
        case .invalidResponse:
            return "Unexpected response from the server."
        case .unauthorized:
            return "Authentication failed."
        case .server(let message):
            return message
        }
    }
}

final class APIClient {
    static let shared = APIClient()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    private var baseURL: URL? {
        let stored = UserDefaults.standard.string(forKey: "x2u.api.baseURL")
        let raw = (stored?.isEmpty == false) ? stored! : "http://localhost:3000/api"
        return URL(string: raw)
    }

    func bootstrapDemoUser(email: String?) async throws -> DemoBootstrapResponse {
        struct Payload: Encodable {
            let email: String?
        }

        return try await request(
            path: "auth/demo-bootstrap",
            method: "POST",
            token: nil,
            body: Payload(email: email)
        )
    }

    func getProfile(token: String) async throws -> ProfileData {
        try await request(path: "auth/profile", method: "GET", token: token, body: Optional<String>.none)
    }

    func updateInterestTopics(_ interestTopics: [String], token: String) async throws -> BackendInterestTopicsResponse {
        struct Payload: Encodable {
            let interestTopics: [String]
        }

        return try await request(
            path: "auth/profile/interests",
            method: "PATCH",
            token: token,
            body: Payload(interestTopics: interestTopics)
        )
    }

    func getWeeklyQuiz(token: String) async throws -> BackendQuizSession {
        try await request(path: "quiz/weekly", method: "GET", token: token, body: Optional<String>.none)
    }

    func getMonthlyQuiz(token: String) async throws -> BackendQuizSession {
        try await request(path: "quiz/monthly", method: "GET", token: token, body: Optional<String>.none)
    }

    func getProgress(token: String) async throws -> BackendProgressSnapshot {
        try await request(path: "progress", method: "GET", token: token, body: Optional<String>.none)
    }

    func getTopicHistory(token: String) async throws -> TopicHistoryResponse {
        try await request(path: "progress/topic-history", method: "GET", token: token, body: Optional<String>.none)
    }

    func submitQuizAnswers(sessionId: Int, answers: [Int: Int], token: String) async throws -> BackendQuizSubmissionResponse {
        struct Payload: Encodable {
            let answers: [String: Int]
        }

        let mappedAnswers = Dictionary(uniqueKeysWithValues: answers.map { (String($0.key), $0.value) })
        return try await request(
            path: "quiz/\(sessionId)/submit",
            method: "POST",
            token: token,
            body: Payload(answers: mappedAnswers)
        )
    }

    func listCourses() async throws -> CoursesResponse {
        try await request(path: "courses", method: "GET", token: nil, body: Optional<String>.none)
    }

    func subscribeToCourse(courseId: Int, token: String) async throws -> [String: String] {
        struct Response: Codable {
            let message: String
        }
        let response: Response = try await request(
            path: "courses/\(courseId)/subscribe",
            method: "POST",
            token: token,
            body: Optional<String>.none
        )
        return ["message": response.message]
    }

    func unsubscribeFromCourse(courseId: Int, token: String) async throws -> [String: String] {
        struct Response: Codable {
            let message: String
        }
        let response: Response = try await request(
            path: "courses/\(courseId)/unsubscribe",
            method: "POST",
            token: token,
            body: Optional<String>.none
        )
        return ["message": response.message]
    }

    func getQuizHistory(token: String) async throws -> QuizHistoryResponse {
        try await request(path: "quiz/history", method: "GET", token: token, body: Optional<String>.none)
    }

    func getQuizReview(sessionId: Int, token: String) async throws -> QuizReviewPayload {
        try await request(path: "quiz/\(sessionId)/review", method: "GET", token: token, body: Optional<String>.none)
    }

    private func request<T: Decodable, B: Encodable>(
        path: String,
        method: String,
        token: String?,
        body: B?
    ) async throws -> T {
        guard var baseURL else {
            throw APIClientError.invalidURL
        }

        if !baseURL.absoluteString.hasSuffix("/") {
            baseURL.appendPathComponent("")
        }

        let url = baseURL.appendingPathComponent(path)

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        if httpResponse.statusCode == 401 {
            throw APIClientError.unauthorized
        }

        if !(200...299).contains(httpResponse.statusCode) {
            if let apiError = try? JSONDecoder().decode(ServerError.self, from: data) {
                throw APIClientError.server(message: apiError.error)
            }
            throw APIClientError.server(message: "Request failed with status \(httpResponse.statusCode).")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIClientError.invalidResponse
        }
    }
}

private struct ServerError: Decodable {
    let error: String
}
