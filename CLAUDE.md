# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ENGAGE-HF is an iOS app for the DOT-HF clinical study. It records Bluetooth measurements (Omron weight scale and blood pressure cuff), saves them to Firestore, and displays medication recommendations based on vitals trends and KCCQ-12 survey responses. Built on the Stanford Spezi framework with SwiftUI.

## Build & Test Commands

```bash
# Build (no code signing)
fastlane build

# Run all tests (requires Firebase emulator running)
fastlane test

# Start Firebase emulator (required for UI tests and simulator runs)
cd ENGAGE-HF-Firebase && npm run prepare && npm run serve:seeded
# Or via Docker:
cd ENGAGE-HF-Firebase && docker-compose up

# Run tests via xcodebuild directly
xcodebuild test -scheme ENGAGEHF -derivedDataPath .derivedData -destination 'platform=iOS Simulator,name=iPhone 17' -skipPackagePluginValidation -skipMacroValidation

# Lint
swiftlint

# Detect unused code
periphery scan
```

Open `ENGAGEHF.xcodeproj` in Xcode to build and run. The app auto-connects to the Firebase emulator when running on the iOS Simulator.

## Architecture

**Spezi Module System**: The app uses Stanford Spezi's dependency injection via `SpeziAppDelegate`. All modules are registered in `ENGAGEHFDelegate.configuration`. Modules use `@Dependency` for inter-module references and are accessed in SwiftUI views via `@Environment`.

**Manager Pattern**: Core business logic lives in 8 manager modules (`ENGAGEHF/Managers/`), each conforming to `Manager` protocol (which extends `Module, EnvironmentAccessible, DefaultInitializable, RefreshableContent`):
- `MessageManager` — server-driven in-app messages
- `VitalsManager` — health data aggregation (weight, BP, heart rate)
- `MedicationsManager` — medication recommendations from backend
- `VideoManager` — educational video collections
- `NotificationManager` — push notification handling
- `UserMetaDataManager` — user organization/metadata
- `NavigationManager` — tab and sheet navigation state
- `HealthMeasurements` — Bluetooth device measurement recording

**Navigation**: `ContentView` manages auth/onboarding state. `Home` provides a `TabView` with 4 tabs: Dashboard, Heart Health, Medications, Education.

**Firebase Backend**: Firestore collections live under `users/{accountId}/` (messages, observations, medicationRecommendations, etc.) plus top-level `videoSections/`, `questionnaires/`, `organizations/`. The backend repo is a git submodule at `ENGAGE-HF-Firebase/`.

**Feature Flags**: Launch arguments in `FeatureFlags.swift` toggle test behaviors (e.g., `--disableFirebase`, `--skipOnboarding`, `--useFirebaseEmulator`, `--setupTestEnvironment`). Used in UI tests and previews.

## Code Style

SwiftLint is strictly configured (`.swiftlint.yml`) with `only_rules` — only explicitly listed rules are active. Key limits:
- Line length: 150 chars
- File length: 500 lines
- Function body: 50 lines
- Closure body: 35 lines
- Type body: 250 lines
- No force unwraps or force casts

All source files require the SPDX license header (REUSE compliance):
```swift
//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
```

## Testing

- **Unit tests**: `ENGAGEHFTests/` — test data logic (vitals aggregation, date parsing, message actions)
- **UI tests**: `ENGAGEHFUITests/` — snapshot/integration tests organized by feature, use feature flags to set up mock data
- **Test plan**: `ENGAGEHF.xctestplan` — retries on failure, code coverage enabled for ENGAGEHF target
- Firebase emulator must be running for UI tests

## Dependencies

All managed via Swift Package Manager through Xcode. Key frameworks:
- **Spezi ecosystem**: Spezi, SpeziAccount, SpeziFirebase, SpeziFirestore, SpeziBluetooth, SpeziDevices, SpeziOmron, SpeziQuestionnaire, SpeziOnboarding, SpeziNotifications
- **Firebase**: Auth, Firestore, Storage, Functions, Messaging
- **HealthKitOnFHIR**: FHIR resource mapping for health data

## Localization

Uses Xcode String Catalogs (`ENGAGEHF/Resources/Localizable.xcstrings`). Supports English and Spanish.
