# Fleet

![Version](https://img.shields.io/badge/version-1.0.0-7B5EA7?style=for-the-badge&labelColor=1A1A2E)
![Platform](https://img.shields.io/badge/platform-iOS_17+-4A90D9?style=for-the-badge&labelColor=1A1A2E)
![License](https://img.shields.io/badge/license-MIT-2ECC8B?style=for-the-badge&labelColor=1A1A2E)
![Swift](https://img.shields.io/badge/swift-5.9-F0845C?style=for-the-badge&labelColor=1A1A2E)

**Your garage, beautifully organized.**

Fleet is an iOS app that helps you manage all your vehicles in one place — track registrations, insurance, recalls, maintenance, and KBB valuations.

## Features

- **Multi-Vehicle Garage** — Track every car you own with high-res photos and at-a-glance status
- **Smart Reminders** — Never miss a registration, insurance renewal, or maintenance window
- **Recall Alerts** — Instant NHTSA recall notifications tied directly to your VIN
- **Live KBB Valuation** — Real-time trade-in and private sale estimates updated monthly
- **Fleet Health Score** — See your overall fleet status at a glance
- **Google Sign-In** — Secure authentication with your Google account

## Screenshots

The app includes four primary screens:

| Garage Home | Car Detail | Alerts & Timeline | KBB Valuations |
|:-----------:|:----------:|:-----------------:|:--------------:|
| Vehicle cards with status badges | Registration, insurance, recalls, service history | Fleet health score, upcoming events | Trade-in, private sale, dealer estimates |

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for project generation)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/iamadawra/fleet.git
   cd fleet
   ```

2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open `Fleet.xcodeproj` in Xcode

4. **Google Sign-In Setup** (optional):
   - Create a project in [Google Cloud Console](https://console.cloud.google.com)
   - Enable Google Sign-In and create an OAuth 2.0 client ID for iOS
   - Replace `PLACEHOLDER-REVERSED-CLIENT-ID` in `Info.plist` with your reversed client ID
   - Add your `GoogleService-Info.plist` to `Fleet/Resources/`

5. Build and run on a simulator or device

> **Note:** The app includes a "Skip for now" option on the login screen for demo purposes.

## Architecture

```
Fleet/
├── Sources/
│   ├── App/              # App entry point
│   ├── Models/           # Data models (Vehicle, Registration, etc.)
│   ├── Views/            # SwiftUI views
│   │   ├── Auth/         # Login & authentication
│   │   ├── Garage/       # Garage home & vehicle cards
│   │   ├── Detail/       # Car detail & status cards
│   │   ├── Alerts/       # Alerts & upcoming events
│   │   ├── Valuations/   # KBB valuation cards
│   │   └── Profile/      # User profile & settings
│   ├── ViewModels/       # View models
│   ├── Services/         # Auth service & sample data
│   └── Theme/            # Colors, gradients, styling
└── Resources/
    ├── Assets.xcassets/  # App icon & colors
    └── Info.plist        # App configuration
```

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
