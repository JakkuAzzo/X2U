import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var apiURLInput: String = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("API Configuration") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("API Base URL")
                            .font(.caption)
                            .foregroundStyle(X2UTheme.slate)

                        TextField("http://localhost:3000/api", text: $apiURLInput)
                            .textFieldStyle(.roundedBorder)
                            .monospaced()

                        Button("Update URL") {
                            appState.setAPIBaseURL(apiURLInput)
                        }
                        .buttonStyle(.bordered)
                        .tint(X2UTheme.accent)
                    }
                    .padding(.vertical, 8)
                }

                Section("Authentication Method") {
                    Picker("Auth Method", selection: Binding(
                        get: { appState.authMethod },
                        set: { appState.setAuthMethod($0) }
                    )) {
                        Text("Demo Bootstrap").tag(AppState.AuthMethod.demoBootstrap)
                        Text("Magic Link").tag(AppState.AuthMethod.magicLink)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Connection Status") {
                    HStack {
                        Text("Status")
                        Spacer()
                        if appState.isConnected {
                            Label("Connected", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Label("Disconnected", systemImage: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }

                    if let email = appState.profileEmail {
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(email)
                                .font(.caption)
                                .foregroundStyle(X2UTheme.slate)
                        }
                    }

                    if let error = appState.syncError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button("Re-Connect") {
                        Task {
                            await appState.ensureConnected()
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(X2UTheme.accent)
                }

                Section("About") {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(X2UTheme.slate)
                    }

                    HStack {
                        Text("Backend")
                        Spacer()
                        Text("X2U")
                            .foregroundStyle(X2UTheme.slate)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                apiURLInput = appState.apiBaseURL
            }
        }
    }
}
