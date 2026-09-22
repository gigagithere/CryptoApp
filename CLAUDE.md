# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CryptoApp is a SwiftUI iOS app for tracking live cryptocurrency prices and running a paper-trading portfolio. It uses Firebase (Auth + Firestore) for accounts and per-user data, and the CoinGecko REST API for market data. Deployment target is iOS 26; Swift 6 language mode with main-actor-by-default isolation. See `README.md` for features, setup, and the architecture diagram.

## Build & Development Commands

- **Build (Xcode)**: open `CryptoApp/CryptoApp.xcodeproj`, select the `CryptoApp` scheme, ⌘B.
- **Run**: ⌘R on an iOS 26+ simulator or device.
- **Tests**: ⌘U, or from the command line (run from `CryptoApp/`, the folder with the `.xcodeproj`):
  ```sh
  xcodebuild test -project CryptoApp.xcodeproj -scheme CryptoApp \
    -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
  ```
  Add `-only-testing:CryptoAppTests` to skip the UI test. Only run one `xcodebuild test` at a time against a given simulator.
- **Build only** (no run/test): same as above with `build` instead of `test`, `-destination 'generic/platform=iOS Simulator'` works and is faster.
- **Sample data / no Firebase account**: launch with `-uiTesting` (already wired in `CryptoAppApp.init`) to run against in-memory sample data as a fake signed-in user.
- **Clean**: Product → Clean Build Folder in Xcode, or delete DerivedData.

### `project.pbxproj` uses explicit file references (no folder sync)

Adding, removing, or moving a `.swift` file needs a matching change in `CryptoApp.xcodeproj/project.pbxproj` (new `PBXFileReference`/`PBXBuildFile` entries and group membership) — Xcode does this for you when you use its UI; when editing files directly, add the same four entries by hand (see how existing files are wired: a `PBXBuildFile` line, a `PBXFileReference` line, a group `children` entry, and — for a `Sources` file — a `PBXSourcesBuildPhase` entry). The same applies to non-Swift resources like `Localizable.xcstrings` (a `PBXResourcesBuildPhase` entry instead of Sources).

## Architecture

MVVM with a thin service layer. No protocol unless it's an I/O seam with more than one real or mock implementation; no `@StateObject`/`@Published`/singletons — everything is `@Observable` and injected via `@Environment`.

```
App/            CryptoAppApp (creates the 4 top-level objects, injects with .environment), RootView,
                MainTabView (native TabView), Route (navigationDestination routing), SampleData (preview/UI-test data)
Models/         Coin, Holding, Transaction, TransactionType, SortOption/SortOrder, AppTheme, error types — one type per file
Services/       CoinRepository (+protocol), CoinService, AuthService, PortfolioFirestoreService (+protocol), WatchlistFirestoreService (+protocol)
ViewModels/     PortfolioViewModel, WatchlistViewModel, AuthFormModel, TradeViewModel — @Observable @MainActor, concrete (no protocols)
Features/       One folder per screen: Home/, CoinDetail/, Portfolio/, Profile/, Auth/, Trading/ — small View structs, one per file
DesignSystem/   Spacing/Radius tokens, FormatStyles (.usd, .usdAmount, .quantity, .percentChangeSigned, ...), shared small views
```

- `CryptoAppApp.init` calls `FirebaseApp.configure()`, creates `AuthService`, `CoinService`, `PortfolioViewModel`, `WatchlistViewModel` once, and injects them with `.environment(...)`. Views read them with `@Environment(AuthService.self)` etc. — never create their own.
- `RootView` shows `AuthView` or `MainTabView` based on `authService.userSession`, and loads coins/portfolio/watchlist on sign-in via `.task(id: userSession?.uid)`.
- Coins are looked up by id from `CoinService.coin(id:)`, never copied into a detail or trade screen (`CoinDetailView(coinID:)`, `TradingModalView(coinID:type:)`) — this is what keeps the price live if a refresh happens while the screen is open.
- `PortfolioViewModel.buy`/`sell` are `async throws`, write one Firestore batch (transaction + holding set-or-delete), and only update local state after the write succeeds — no local/remote divergence on failure.
- `TabView { Tab }` with a `NavigationStack` per tab and `navigationDestination(for: Route.self)` (`App/Route.swift`); no `NavigationLink(destination:)`.
- Formatting goes through `DesignSystem/FormatStyles.swift` (`Text(value, format: .usd)` etc.), not hand-rolled `NumberFormatter`/`DateFormatter`.

## Swift 6 concurrency

The app target has `SWIFT_APPROACHABLE_CONCURRENCY = YES` and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`, so everything in the app module is main-actor by default. Things that must run off the main actor are marked explicitly:
- Models are `nonisolated struct` (and their `extension`s need `nonisolated extension` too).
- The I/O layer (`CoinRepositoryProtocol`/`CoinRepository`, the two Firestore service protocols/classes) is `nonisolated`, with the actual network/Firestore/JSON-decoding calls marked `@concurrent`.
- `FirebaseFirestore`/`FirebaseAuth` are imported `@preconcurrency`; `CoinRepository` is `@unchecked Sendable` (its state is an immutable `URLSession` + `UserDefaults`).
- Test doubles under `CryptoAppTests/Support/` are `@unchecked Sendable`.

Tests and UI tests build in plain Swift 6 mode (no approachable concurrency / default isolation), since they're driving `@MainActor` types from test code.

## Localization

`CryptoApp/CryptoApp/Localizable.xcstrings` covers English (source) and Polish. Conventions to follow when adding UI text:
- Plain static text: pass a string literal to `Text`/`Button`/`Label`/`.navigationTitle`/etc. as usual — these use the `LocalizedStringKey` overload and look themselves up in the catalog automatically. Add a matching entry (exact text as the key) to the catalog.
- A `View`'s own `String`-typed property (e.g. a `title: String` parameter) does **not** auto-localize when you call `Text(title)` inside it — type it `LocalizedStringKey` instead (see `InfoItem`, `PortfolioLinkRow`, `LabeledValue` for the pattern already in place).
- Plural counts (e.g. "1 holding" vs "3 holdings"): interpolate the count normally (`"\(count) holding"`, singular in source) and give the catalog entry `"variations": {"plural": {...}}` per language (English needs `one`/`other`; Polish needs `one`/`few`/`many`/`other`). Don't use the `^[...](inflect: true)` grammar-agreement markup — it wasn't reliable to hand-author without Xcode's own extraction, and plain plural variation covers every case in this app.
- A dynamic sentence with English glue words around interpolated values (e.g. "You don't own any %@") needs its own catalog entry, keyed by the literal text with `%@`/`%lld` where each interpolation was. Two interpolated values just concatenated with a space or punctuation (e.g. `"\(trade.type.title) \(coin.name)"`, both already-localized/formatted pieces) don't need one — they render correctly by falling back to the raw interpolation.
- `xcstringstool compile <file> -o <dir> -l en -l pl` (at `/Applications/Xcode.app/Contents/Developer/usr/bin/xcstringstool`) compiles the catalog to `.strings`/`.stringsdict` without a full app build — useful for checking a new entry's plural rules or format-key shape before running the whole test suite. Note: **`xcodebuild build` does not auto-extract new strings into the `.xcstrings` file** the way Xcode's own interactive build sometimes does — new keys must be added to the catalog by hand.
- `pl` is a known region in the Xcode project (`project.pbxproj` → `knownRegions`).

## Firebase

- `GoogleService-Info.plist` is committed (normal for a Firebase iOS app; it's a client identifier, not a secret) but only safe because the API key is restricted to this app's bundle ID and `firestore.rules` enforces per-user ownership. See `firestore.rules`, `firebase.json`, and the README's Security section before changing how data is stored.
- Data shape: `users/{userId}/holdings/{coinId}`, `users/{userId}/transactions/{transactionId}`, `users/{userId}/watchlist/{coinId}`. Deploy rule changes with `firebase deploy --only firestore:rules`.

## Tests

- `CryptoAppTests/` (Swift Testing): coin decoding, `Decimal` price conversion, `Holding` math, `FormatStyle`s, portfolio totals, `CoinService`/`CoinRepository` (stubbed `URLProtocol`), `PortfolioViewModel`/`TradeViewModel` (mock Firestore service). Doubles live in `CryptoAppTests/Support/`.
- `CryptoAppUITests/`: one XCTest smoke test launched with `-uiTesting`, walking Home → search → coin detail → trade sheet (cancel only) → portfolio → profile.
- Write tests in the same change as the fix/feature they cover; keep using Swift Testing (`@Test`/`#expect`) for new unit tests, not XCTest.

## Conventions worth keeping

- One type per file (see `Models/`, `Features/*/`).
- No `some View` fragments as `private var`s for anything non-trivial — extract a small `View` struct instead.
- `@Environment` for shared state, `@State private` only for view-owned state.
- Modern APIs only: `foregroundStyle` (not `foregroundColor`), `Text(_:format:)`/`FormatStyle` (not `NumberFormatter`/`DateFormatter`), `NavigationLink(value:)` (not `destination:`), `.overlay { }` (not `.overlay(Shape...)`), `Date.now` (not `Date()`).
