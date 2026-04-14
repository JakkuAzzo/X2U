# X2U iOS App

X2U is an iOS SwiftUI app that extends the Cyber2U concept from cybersecurity-only training into multiple learning domains.

## Implemented Features

- Browse multiple course areas
- Subscribe and unsubscribe to courses
- Complete quizzes directly in-app
- Track completion and latest score in a dedicated progress screen
- Persist subscriptions and progress locally with UserDefaults

## Domains Included

- Cybersecurity
- Data & AI
- Product & Design
- Business & Finance

## Run in Xcode

1. From this folder, generate the project:
   - xcodegen generate
2. Open the project:
   - open X2U.xcodeproj
3. Choose the X2U scheme and an iOS Simulator device.
4. Run.

## CLI Validation Commands

- Build:
  - xcodebuild build -project X2U.xcodeproj -scheme X2U -destination 'platform=iOS Simulator,OS=18.5,name=iPhone 16'
- Tests:
  - xcodebuild test -project X2U.xcodeproj -scheme X2U -destination 'platform=iOS Simulator,OS=18.5,name=iPhone 16'
