import Foundation

enum SeedData {
    static let courses: [Course] = [
        Course(
            domain: .cybersecurity,
            title: "Phishing Defense Fundamentals",
            summary: "Spot social engineering patterns and safely triage suspicious messages.",
            level: "Beginner",
            interestTopics: ["phishing", "social_engineering", "safe_browsing"],
            quizzes: [
                CourseQuiz(
                    title: "Inbox Threat Triage",
                    questions: [
                        QuizQuestion(prompt: "Which signal is the strongest phishing indicator?", options: ["Branded logo", "Urgent password reset + unknown sender domain", "Long email signature", "Formal greeting"], correctIndex: 1),
                        QuizQuestion(prompt: "What should you do before clicking an attachment from payroll?", options: ["Open quickly", "Forward to everyone", "Verify sender through a trusted channel", "Reply with personal details"], correctIndex: 2),
                        QuizQuestion(prompt: "A message asks for MFA code by phone. Best response?", options: ["Share code if caller sounds official", "Decline and report", "Postpone and share later", "Ask for manager approval then share"], correctIndex: 1)
                    ]
                )
            ]
        ),
        Course(
            domain: .dataAndAi,
            title: "Data Literacy for Teams",
            summary: "Interpret trends, avoid common metric traps, and make better decisions.",
            level: "Intermediate",
            interestTopics: ["data_privacy", "incident_response"],
            quizzes: [
                CourseQuiz(
                    title: "Metric Quality Check",
                    questions: [
                        QuizQuestion(prompt: "A conversion rate rises while traffic halves. First check?", options: ["Celebration post", "Sample size and traffic source changes", "New logo color", "Randomize dashboard colors"], correctIndex: 1),
                        QuizQuestion(prompt: "What is survivorship bias?", options: ["Only seeing successful examples", "A storage format", "A type of chart", "A security bug"], correctIndex: 0),
                        QuizQuestion(prompt: "Best chart for monthly trend over time?", options: ["Pie chart", "Line chart", "Treemap", "Word cloud"], correctIndex: 1)
                    ]
                )
            ]
        ),
        Course(
            domain: .productAndDesign,
            title: "UX Decision Making",
            summary: "Choose improvements through evidence, usability heuristics, and feedback loops.",
            level: "Beginner",
            interestTopics: ["safe_browsing", "identity_theft"],
            quizzes: [
                CourseQuiz(
                    title: "Usability Sprint Review",
                    questions: [
                        QuizQuestion(prompt: "Most useful first step before redesigning onboarding?", options: ["Rebuild everything", "Review session recordings and drop-off points", "Change fonts only", "Delete analytics"], correctIndex: 1),
                        QuizQuestion(prompt: "A good success metric for onboarding is...", options: ["Number of screens", "Time to first key action", "Total color palette", "Length of privacy policy"], correctIndex: 1),
                        QuizQuestion(prompt: "What does iterative design prioritize?", options: ["One perfect release", "Small validated improvements", "No user testing", "Monthly visual overhauls only"], correctIndex: 1)
                    ]
                )
            ]
        ),
        Course(
            domain: .businessAndFinance,
            title: "Financial Basics for Builders",
            summary: "Understand margin, runway, and practical budgeting for small products.",
            level: "Intermediate",
            interestTopics: ["ransomware", "device_security", "password_hygiene"],
            quizzes: [
                CourseQuiz(
                    title: "Runway and Margin",
                    questions: [
                        QuizQuestion(prompt: "Runway is best described as...", options: ["Time until cash out at current burn", "Total annual revenue", "Gross margin percentage", "Employee count"], correctIndex: 0),
                        QuizQuestion(prompt: "Gross margin improves when...", options: ["COGS per sale decreases", "Headcount grows", "Marketing spend doubles", "Churn increases"], correctIndex: 0),
                        QuizQuestion(prompt: "A healthy budget process usually includes...", options: ["No variance review", "Planned vs actual tracking", "Only quarterly logging", "Ignoring fixed costs"], correctIndex: 1)
                    ]
                )
            ]
        )
    ]
}
