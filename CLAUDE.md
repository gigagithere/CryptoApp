# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SwiftUI-based iOS cryptocurrency tracking application that displays live coin prices, market data, and charts. The app uses Firebase for authentication and the CoinGecko API for cryptocurrency data.

## Build & Development Commands

This is an Xcode project. Common development tasks:
- **Build**: Open `CryptoApp/CryptoApp.xcodeproj` in Xcode and use Cmd+B
- **Run**: Use Cmd+R in Xcode or the play button
- **Tests**: Use Cmd+U in Xcode to run unit and UI tests
- **Clean**: Product → Clean Build Folder in Xcode

## Architecture & Code Organization

### Project Structure
- `/CryptoApp/CryptoApp/` - Main app source code
- `/CryptoAppTests/` - Unit tests
- `/CryptoAppUITests/` - UI tests

### Key Architectural Patterns

**MVVM Architecture**: The app follows Model-View-ViewModel pattern:
- **Models**: `Coin.swift` defines the core data structure with CoinGecko API mapping
- **ViewModels**: Observable classes ending in `*ViewModel.swift` handle business logic and state management
- **Views**: SwiftUI views handle UI presentation

**Service Layer**: 
- `AuthService.swift` - Singleton for Firebase authentication (`@MainActor` class)
- `CoinRepository.swift` - Protocol-based data layer for API calls with async/await

**Dependency Injection**: ViewModels are injected into views via `@StateObject` and passed down the hierarchy

### Authentication Flow
The app uses Firebase Auth with a conditional root view in `ContentView.swift`:
- If `userSession != nil` → Shows `MainTabView` (authenticated state)
- If `userSession == nil` → Shows `LoginView` (unauthenticated state)

### Data Flow
1. `HomeViewModel` fetches coins via `CoinRepository` using async/await
2. Coin data is shared between `HomeViewModel` and `TopMoversViewModel`
3. Search functionality filters coins in real-time through published properties
4. All ViewModels are `@MainActor` for UI thread safety

### Navigation Structure
- Custom tab bar implementation in `MainTabView.swift` with animated transitions
- `NavigationStack` used for deep navigation within tabs
- Tab enum defines available tabs (`home`, `profile`)

### Key Components
- **Custom Search Bar**: `CustomSearchBar.swift` with real-time filtering
- **Chart Integration**: `ChartView.swift` displays 7-day price sparklines
- **Reusable UI**: Components in `/Components/` folder (buttons, text fields, dividers)

### State Management
- `@StateObject` for ViewModel ownership
- `@Published` properties for reactive UI updates
- `@AppStorage` for dark mode persistence
- Firebase Auth state drives app-wide authentication status

### API Integration
- CoinGecko REST API integration with structured JSON decoding
- URL construction with query parameters for market data
- Error handling with Swift's structured concurrency

### Firebase Integration
- `GoogleService-Info.plist` required for Firebase configuration
- `AppDelegate` handles Firebase initialization
- Kingfisher dependency for image loading/caching

## Development Notes

- The app supports dark mode with `@AppStorage("isDarkModeOn")`
- All async operations use Swift's async/await pattern
- ViewModels use `@MainActor` to ensure UI updates happen on the main thread
- The project uses SwiftUI preview providers for development
- Custom color assets defined in `Assets.xcassets`