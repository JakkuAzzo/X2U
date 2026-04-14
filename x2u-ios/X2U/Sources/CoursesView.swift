import SwiftUI

struct CoursesView: View {
    @EnvironmentObject private var appState: AppState
    @State private var activeCourse: CourseKind?

    private enum CourseKind {
        case cybersecurity
        case driving

        var title: String {
            switch self {
            case .cybersecurity: return "CyberSecurity"
            case .driving: return "Driving"
            }
        }
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(activeCourse?.title ?? "Courses")
                .navigationBarTitleDisplayMode(.inline)
                .x2uScreenBackground()
        }
    }

    @ViewBuilder
    private var content: some View {
        if let activeCourse {
            switch activeCourse {
            case .cybersecurity:
                CyberSecurityCoursesView(onSwitchCourse: { self.activeCourse = nil })
            case .driving:
                CoursesLibraryView(onSwitchCourse: { self.activeCourse = nil })
            }
        } else {
            ScrollView {
                VStack(spacing: 18) {
                    header

                    VStack(spacing: 12) {
                        coursePickerCard(
                            title: "CyberSecurity",
                            subtitle: "Open the learning catalog with cybersecurity, data, design, and finance courses.",
                            symbol: "shield.lefthalf.filled",
                            action: { activeCourse = .cybersecurity }
                        )

                        coursePickerCard(
                            title: "Driving",
                            subtitle: "Open driving theory lessons, subscriptions, and quizzes.",
                            symbol: "car",
                            action: { activeCourse = .driving }
                        )
                    }
                }
                .padding(20)
            }
            .background(X2UTheme.pageBackground)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image("X2ULogo")
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)
                .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 6)

            Text("Courses")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(X2UTheme.ink)

            Text("Choose a learning track to continue.")
                .foregroundStyle(X2UTheme.slate)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func coursePickerCard(title: String, subtitle: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            CardView {
                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: symbol)
                        .font(.title2)
                        .foregroundStyle(X2UTheme.accent)
                        .frame(width: 40, height: 40)
                        .background(X2UTheme.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(X2UTheme.ink)

                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(X2UTheme.slate)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(X2UTheme.slate)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct CyberSecurityCoursesView: View {
    @EnvironmentObject private var appState: AppState
    let onSwitchCourse: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                topBar

                ForEach(LearningDomain.allCases) { domain in
                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(domain.rawValue)
                                .font(.headline)
                                .foregroundStyle(X2UTheme.ink)

                            ForEach(appState.courses.filter { $0.domain == domain }) { course in
                                NavigationLink(value: course) {
                                    CourseRow(course: course)
                                }
                                .buttonStyle(.plain)

                                if course.id != appState.courses.filter({ $0.domain == domain }).last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationDestination(for: Course.self) { course in
            CourseDetailView(course: course)
        }
        .background(X2UTheme.pageBackground)
    }

    private var topBar: some View {
        HStack {
            Button("Switch Course") {
                onSwitchCourse()
            }
            .buttonStyle(.bordered)
            .tint(X2UTheme.accent)

            Spacer()

            Image(systemName: "shield.lefthalf.filled")
                .foregroundStyle(X2UTheme.accent)
        }
    }
}

private struct CourseRow: View {
    @EnvironmentObject private var appState: AppState
    let course: Course

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(course.title, systemImage: course.domain.symbol)
                    .font(.headline)
                Spacer()
                Text(course.level)
                    .font(.caption)
                    .foregroundStyle(X2UTheme.slate)
            }

            Text(course.summary)
                .font(.subheadline)
                .foregroundStyle(X2UTheme.slate)

            HStack {
                Text(appState.isSubscribed(course) ? "Subscribed" : "Not Subscribed")
                    .font(.caption)
                    .foregroundStyle(appState.isSubscribed(course) ? X2UTheme.accent : X2UTheme.slate)
                Spacer()
                Text("\(Int(appState.completionRatio(for: course) * 100))% complete")
                    .font(.caption)
                    .foregroundStyle(X2UTheme.slate)
            }
        }
        .padding(.vertical, 4)
    }
}
