import Foundation

enum LearningDomain: String, Codable, CaseIterable, Identifiable {
    case cybersecurity = "Cybersecurity"
    case dataAndAi = "Data & AI"
    case productAndDesign = "Product & Design"
    case businessAndFinance = "Business & Finance"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .cybersecurity: return "shield.lefthalf.filled"
        case .dataAndAi: return "cpu"
        case .productAndDesign: return "paintpalette"
        case .businessAndFinance: return "chart.line.uptrend.xyaxis"
        }
    }
}

struct QuizQuestion: Codable, Identifiable, Hashable {
    let id: UUID
    let prompt: String
    let options: [String]
    let correctIndex: Int

    init(id: UUID = UUID(), prompt: String, options: [String], correctIndex: Int) {
        self.id = id
        self.prompt = prompt
        self.options = options
        self.correctIndex = correctIndex
    }
}

struct CourseQuiz: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let questions: [QuizQuestion]

    init(id: UUID = UUID(), title: String, questions: [QuizQuestion]) {
        self.id = id
        self.title = title
        self.questions = questions
    }
}

struct Course: Codable, Identifiable, Hashable {
    let id: UUID
    let domain: LearningDomain
    let title: String
    let summary: String
    let level: String
    let interestTopics: [String]
    let quizzes: [CourseQuiz]

    init(id: UUID = UUID(), domain: LearningDomain, title: String, summary: String, level: String, interestTopics: [String], quizzes: [CourseQuiz]) {
        self.id = id
        self.domain = domain
        self.title = title
        self.summary = summary
        self.level = level
        self.interestTopics = interestTopics
        self.quizzes = quizzes
    }
}

struct QuizAttempt: Codable, Hashable {
    let quizID: UUID
    let score: Int
    let total: Int
    let completedAt: Date
}

struct CourseProgress: Codable, Hashable {
    var completedQuizIDs: Set<UUID>
    var attempts: [QuizAttempt]

    static let empty = CourseProgress(completedQuizIDs: [], attempts: [])
}

struct DemoBootstrapResponse: Codable {
    let token: String
    let userId: Int
    let email: String
    let completedSessions: Int
}

struct ProfileData: Codable {
    let id: Int
    let email: String
    let interestTopics: [String]
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case interestTopics
        case createdAt = "created_at"
    }
}

struct BackendProgressSnapshot: Codable {
    let totalQuizzesCompleted: Int
    let averageScore: Double
    let improvementPercentage: Double
    let topicScores: [String: Double]

    static let empty = BackendProgressSnapshot(
        totalQuizzesCompleted: 0,
        averageScore: 0,
        improvementPercentage: 0,
        topicScores: [:]
    )
}

struct TopicHistoryPoint: Codable, Identifiable {
    let sessionId: Int
    let completedAt: String
    let totalScore: Double
    let topicScores: [String: Double]

    var id: Int { sessionId }
}

struct TopicHistoryResponse: Codable {
    let history: [TopicHistoryPoint]
}

struct BackendQuizOption: Codable, Identifiable {
    let id: Int
    let optionText: String

    enum CodingKeys: String, CodingKey {
        case id
        case optionText = "option_text"
    }
}

struct BackendQuizQuestion: Codable, Identifiable {
    let id: Int
    let questionText: String
    let questionType: String
    let options: [BackendQuizOption]

    enum CodingKeys: String, CodingKey {
        case id
        case questionText = "question_text"
        case questionType = "question_type"
        case options
    }
}

struct BackendQuizSession: Codable {
    let sessionId: Int
    let questions: [BackendQuizQuestion]
}

struct BackendInterestTopicsResponse: Codable {
    let interestTopics: [String]
}

struct BackendQuizSubmissionResponse: Codable {
    let score: Double
    let passed: Bool
    let correctAnswers: Int
    let totalQuestions: Int
    let topicScores: [String: Double]
    let progress: BackendProgressSnapshot
    let feedback: String
}

struct DrivingTheoryCourse: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    let courseCategory: String
    let level: String
    let durationMinutes: Int
    let totalQuestions: Int
    let passingScore: Double

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case courseCategory = "courseCategory"
        case level
        case durationMinutes = "durationMinutes"
        case totalQuestions = "totalQuestions"
        case passingScore = "passingScore"
    }
}

struct CoursesResponse: Codable {
    let courses: [DrivingTheoryCourse]
}

struct QuizHistoryItem: Codable, Identifiable {
    let sessionId: Int
    let sessionType: String
    let startedAt: String
    let completedAt: String
    let totalScore: Double
    let passed: Bool
    let questionCount: Int

    var id: Int { sessionId }

    enum CodingKeys: String, CodingKey {
        case sessionId
        case sessionType
        case startedAt
        case completedAt
        case totalScore
        case passed
        case questionCount
    }
}

struct QuizHistoryResponse: Codable {
    let sessions: [QuizHistoryItem]
}

struct QuizOption: Codable, Identifiable {
    let id: Int
    let optionText: String

    enum CodingKeys: String, CodingKey {
        case id
        case optionText = "option_text"
    }
}

struct QuizReviewQuestion: Codable, Identifiable {
    let questionId: Int
    let questionText: String
    let questionType: String
    let selectedOptionId: Int
    let correctOptionId: Int
    let selectedOptionText: String
    let correctOptionText: String
    let isCorrect: Bool
    let options: [QuizOption]

    var id: Int { questionId }

    enum CodingKeys: String, CodingKey {
        case questionId
        case questionText
        case questionType
        case selectedOptionId
        case correctOptionId
        case selectedOptionText
        case correctOptionText
        case isCorrect
        case options
    }
}

struct QuizReviewPayload: Codable, Identifiable {
    let sessionId: Int
    let sessionType: String
    let completedAt: String
    let totalScore: Double
    let passed: Bool
    let questions: [QuizReviewQuestion]

    var id: Int { sessionId }
}
