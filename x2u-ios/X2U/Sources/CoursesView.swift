import SwiftUI

struct CoursesView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                ForEach(LearningDomain.allCases) { domain in
                    Section(domain.rawValue) {
                        ForEach(appState.courses.filter { $0.domain == domain }) { course in
                            NavigationLink(value: course) {
                                CourseRow(course: course)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Courses")
            .navigationDestination(for: Course.self) { course in
                CourseDetailView(course: course)
            }
            .x2uScreenBackground()
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
