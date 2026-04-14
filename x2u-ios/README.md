# X2U iOS App

X2U is the mobile client for the X2U learning platform. It is built with SwiftUI and focuses on quick course browsing, quiz completion, and progress tracking on iPhone and iPad.

## What the App Does

- Shows available learning tracks from the X2U backend
- Lets learners subscribe and unsubscribe from courses
- Supports in-app quiz sessions with immediate scoring
- Displays course progress, completion ratios, and recent performance
- Persists local state so progress survives app relaunches

## Included Domains

The app currently includes learning content in these areas:

- Cybersecurity
- Data & AI
- Product & Design
- Business & Finance

## How It Fits the Project

The iOS app is one part of the broader X2U project. The repo root contains the backend and supporting web tooling, while this directory contains the native mobile experience.

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
