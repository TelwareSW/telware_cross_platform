# Telware Cross-Platform Team Repository

<!-- STATIC ANALYSIS BADGES -->

[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=TelwareSW_telware_cross_platform&metric=ncloc)](https://sonarcloud.io/summary/new_code?id=TelwareSW_telware_cross_platform)
[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=TelwareSW_telware_cross_platform&metric=sqale_index)](https://sonarcloud.io/summary/new_code?id=TelwareSW_telware_cross_platform)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=TelwareSW_telware_cross_platform&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=TelwareSW_telware_cross_platform)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=TelwareSW_telware_cross_platform&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=TelwareSW_telware_cross_platform)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=TelwareSW_telware_cross_platform&metric=vulnerabilities)](https://sonarcloud.io/summary/new_code?id=TelwareSW_telware_cross_platform)

Welcome to the **Telware Cross-Platform Team's** repository! This project is part of the Telware initiative to recreate the Telegram app. Our team is responsible for building the **Flutter-based cross-platform implementation**, ensuring seamless functionality across Android, iOS, and other supported devices.

## Table of Contents

1. [Project Overview](#project-overview)
2. [Setup Instructions](#setup-instructions)
3. [Project Structure](#project-structure)
4. [Development Guidelines](#development-guidelines)
5. [Testing](#testing)
6. [Contributing](#contributing)
7. [License](#license)
8. [Additional Documentation](#additional-documentation)

---

## Project Overview

This repository contains the cross-platform codebase developed using Flutter. Our responsibilities include:

- Building the core UI and app logic.
- Ensuring feature parity across platforms (Android, iOS).
- Collaborating with Backend, Frontend, DevOps, and Testing teams.
- Delivering a high-quality, performant, and reliable application.

For a detailed understanding of the project workflow, refer to [docs/PROJECT_FLOW.md](docs/PROJECT_FLOW.md).

## Setup Instructions

### Prerequisites

- **Flutter SDK**: Version `3.24.3` ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: Bundled with Flutter
- **Development Environment**:
  - Android Studio (for Android builds)
- **Access to Backend Services**: Contact the backend team for API credentials and documentation.

### Steps to Run the Project

1. Clone the repository:
   ```bash
   git clone https://github.com/TelwareSW/telware_cross_platform.git
   cd telware_cross_platform
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app on a connected device or emulator:
   ```bash
   flutter run
   ```

4. To build platform-specific packages:
   - **Android**: `flutter build apk`
   - **iOS**: `flutter build ios`

---

## Project Structure

```plaintext
.
├── lib/                # Core application code
│   ├── core/           # Core functionality (e.g., API calls, state management)
|   |   ├── classes/    # Custom classes
|   |   ├── constants/  # App constants
│   |   ├── mocks/      # Mock data for testing
│   |   ├── models/     # Data models
|   |   ├── providers/  # State management providers
|   |   ├── routes/     # Navigation routes
|   |   ├── services/   # API services
|   |   ├── theme/      # App themes
|   |   ├── view/       # Shared UI components
│   |   └── utils.dart  # Utility functions
│   ├── features/       # Application features (e.g., chat, settings)
|   |   ├── example/    # Example feature
|   |   |   ├── repository/  # Data repository
|   |   |   ├── services/    # Feature-specific services
|   |   |   ├── view/       # Feature-specific UI components
|   |   |   └── view_model/ # Feature-specific logic
│   |   └── ...         # Other features
│   ├── .env.example    # Example environment variables
│   ├── .env            # Local environment variables
│   └── main.dart       # Application entry point
├── test/               # Unit and widget tests
├── docs/               # Documentation files
├── pubspec.yaml        # Flutter dependencies configuration
└── README.md           # Project overview and setup
```

---

## Development Guidelines

- **Coding Standards**: Follow the guidelines defined in [docs/CODING_GUIDELINES.md](docs/CODING_GUIDELINES.md).
- **Branching Strategy**: Use feature branches and maintain a linear Git history. Refer to [docs/PROJECT_FLOW.md](docs/PROJECT_FLOW.md).
- **Commit Messages**: Use the [Conventional Commits](https://www.conventionalcommits.org/) format.

---

## Testing

1. Run unit tests:
   ```bash
   flutter test
   ```

2. Run integration tests:
   ```bash
   flutter drive --target=test_driver/app.dart
   ```

For more details, refer to [docs/TESTING.md](docs/TESTING.md).

---

## Contributing

We welcome contributions from all team members! To contribute:

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature`.
3. Commit your changes: `git commit -m "feat: your feature description"`.
4. Push to your branch: `git push origin feature/your-feature`.
5. Submit a pull request.

Refer to [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) for more information.

---

## Additional Documentation

- [Architecture Overview](docs/ARCHITECTURE.md)
- [Contributing Guidelines](docs/CONTRIBUTING.md)
- [Testing Guide](docs/TESTING.md)
- [Coding Standards](docs/CODING_GUIDELINES.md)
- [Project Flow](docs/PROJECT_FLOW.md)

For questions or further assistance, feel free to reach out via the project Slack channel or raise an issue in this repository.
