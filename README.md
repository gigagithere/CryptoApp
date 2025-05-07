# 🚀 CryptoApp

A cryptocurrency tracking app for iOS built with **SwiftUI** and **Firebase**. Displays live prices, historical price charts and coin details. Created as a concept project to learn and demonstrate SwiftUI, Combine, and authentication flow.

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![iOS](https://img.shields.io/badge/iOS-15+-blue)
![Xcode](https://img.shields.io/badge/Xcode-15-green)
![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)

## 🛠 Technologies Used

- Swift  
- SwiftUI  
- Combine  
- Firebase Auth (login/register)  
- Kingfisher (remote image loading)  
- Xcode 15+  
- iOS 15.0+

## 📸 App Screenshots

| Login | Home | Coin Detail | Profile |
|-------|------|-------------|---------|
| <img width="200" alt="login" src="https://github.com/user-attachments/assets/e3a8f240-47e1-4143-b06e-4487120e4f2b" /> | <img width="200" alt="home" src="https://github.com/user-attachments/assets/2a417f77-21ed-4c82-a462-51360da3c3ad" /> | <img width="200" alt="detail" src="https://github.com/user-attachments/assets/3c474a01-555b-45b6-902b-0b297220763e" /> | <img width="200" alt="profile" src="https://github.com/user-attachments/assets/3b871c85-1863-4ace-b73b-480315999ba0" /> |
## 📋 General Info


**CryptoApp** is a simple but modern iOS app that shows real-time cryptocurrency prices using an external API. It features:

- A searchable and sortable list of top cryptocurrencies  
- A detail view with historical chart and coin metrics  
- Firebase-based custom login & registration flow  
- Local settings UI (e.g., dark mode toggle)
- Secure session handling using Combine & SwiftUI state management  

⚠️ This app is **for educational/demo purposes only** – no real transactions are possible.

## 🚀 Features

- 🔎 Live search for coins
- 📈 Line chart with historic pricing
- ✅ Firebase login/register
- 👤 User profile & settings
- 💡 Combine used for session updates

## 🧠 Learning Goals

This project was built to explore:

- SwiftUI navigation and layout techniques
- Asynchronous data fetching using async/await
- Using Combine for reactive state management
- Firebase Authentication integration
- Modularizing UI in SwiftUI

## 🧪 Setup

To run the project:

1. Clone the repository  
   ```bash
   git clone https://github.com/gigagithere/CryptoApp.git
   ```
2. Open in Xcode  
3. Add your Firebase config (`GoogleService-Info.plist`)  
4. Run on a real device or simulator with iOS 15+

## 🔗 API Reference

Data is fetched from the public [CoinGecko API](https://www.coingecko.com/en/api), no API key required:
https://api.coingecko.com/api/v3/coins/markets

## 📁 Project Structure Overview

```
CryptoApp/
├── App/                          # App entry point and main SwiftUI logic
│   ├── ContentView.swift
│   └── ContentViewModel.swift
│
├── CoinList/                     # List of all cryptocurrencies
│   └── CoinList.swift
│   └── SingleRowView.swift
│
├── CoinDetail/                   # Coin detail view with chart and info sections
│   ├── CoinDetailView.swift
│   ├── BackgroundDetailView.swift
│   ├── ChartView.swift
│   └── InfoView.swift
│
├── Components/                   # Reusable UI components (buttons, dividers, etc.)
│   ├── DividerView.swift
│   ├── ReusableButton.swift
│   ├── CustomSearchBar.swift
│   ├── CustomTestListStyle.swift
│   └── SortEnum.swift
│
├── Extensions/                   # Swift type extensions
│   ├── Date+.swift
│   └── Double+.swift
│   └── String+.swift
│
├── Home/                         # Main screen with live prices and search
│   ├── HomeView.swift
│   ├── HomeViewModel.swift
│   ├── TopMoversBar/             # Horizontal scroll view showing trending coins
│   │   ├── TopMoversView.swift
│   │   └── TopMoversViewModel.swift
│
├── TabBar/                       # Bottom tab bar navigation across main screens
│       ├── MainTabView.swift   
│
├── Login/                        # Login screen and logic
│   ├── LoginView.swift
│   └── LoginViewModel.swift
│
├── Registration/                # Registration screen and logic
│   ├── RegistrationView.swift
│   └── RegistrationViewModel.swift
│
├── Models/                      # Data models
│   ├── Coin.swift   
│
├── Profile/                     # Profile view and settings
│   ├── ProfileView.swift
│
├── Services/                    # Shared services like authentication, fetching data from API
│   └── AuthService.swift
│   └── CoinRepository.swift
│
├── Assets.xcassets              # App assets and icons
├── GoogleService-Info.plist     # Firebase configuration file
└── CryptoAppTests/              # Unit tests
```

## ✅ What’s done well:

- Clean MVVM Structure: ViewModels (HomeViewModel, AuthViewModel, etc.) are separated from Views, promoting clear data flow and testability.  
- Full Sort & Filter Implementation: Users can both search and sort the coin list by price, market cap, or daily change, in ascending or descending order.  
- Responsive Async Data Loading: Uses async/await and a dedicated CoinRepository to fetch live market data cleanly and handle errors at the network layer.  
- Modular, Reusable UI Components: Common UI pieces (search bar, buttons, dividers, list styles) are extracted into the Components/ folder for easy reuse.  
- Custom Charts & Detail Views: The ChartView and InfoView combine to present historical price data in a polished, SwiftUI-native way.  
- Firebase Authentication: Complete login and registration flows backed by AuthService, with reactive session tracking via Combine and @Published state.  
- Dark Mode & Settings: Profile screen includes toggles (e.g. dark mode) persisted via @AppStorage, providing a user-preference layer out of the box.

## 💡 Room for Improvement

- Implement the missing **Edit Profile** flow (form + photo picker + save to Firebase)  
- Add **Pull-to-Refresh** on the home screen for manual data updates  
- Show **loading indicators** (e.g. `ProgressView` or skeletons) during network requests  
- Introduce a basic **offline state** (message or UI fallback when no connection)  
- Surface **authentication errors** in UI (alerts/snackbars) instead of silent failures
- (Optional) Add biometric login via Face ID for secure authentication

## 📄 Status

Project is: **Functional prototype – actively improving UX, stability, and structure**

## ✉️ Contact

Created by **Bartosz Mrugala**  
Feel free to reach out on GitHub: [@gigagithere](https://github.com/gigagithere)

## 📝 License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
