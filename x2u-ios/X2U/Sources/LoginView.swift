import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    @State private var emailInput: String = ""
    @State private var apiURLInput: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                X2UTheme.pageBackground
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    X2ULogoView(size: 96)
                        .shadow(color: .black.opacity(0.15), radius: 14, x: 0, y: 6)

                    Text("Welcome to X2U")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(X2UTheme.ink)

                    Text("Sign in to connect to the backend and access your learning data.")
                        .font(.subheadline)
                        .foregroundStyle(X2UTheme.slate)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)

                    CardView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Email")
                                .font(.caption)
                                .foregroundStyle(X2UTheme.slate)

                            TextField("you@example.com", text: $emailInput)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .keyboardType(.emailAddress)
                                .textFieldStyle(.roundedBorder)

                            Text("API Base URL")
                                .font(.caption)
                                .foregroundStyle(X2UTheme.slate)

                            TextField("http://localhost:3000/api", text: $apiURLInput)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textFieldStyle(.roundedBorder)
                                .monospaced()

                            Button {
                                Task {
                                    appState.setAPIBaseURL(apiURLInput)
                                    let trimmedEmail = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                    await appState.connectDemoUser(email: trimmedEmail.isEmpty ? nil : trimmedEmail)
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    if appState.isSyncing {
                                        SwiftUI.ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Sign In")
                                            .fontWeight(.semibold)
                                    }
                                    Spacer()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(X2UTheme.accent)
                            .disabled(appState.isSyncing)

                            if let error = appState.syncError {
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                apiURLInput = appState.apiBaseURL
            }
        }
    }
}
