# ConfigHub: Dynamic iOS App Configuration

ConfigHub is a sophisticated iOS application built with SwiftUI that demonstrates a professional, scalable remote configuration system. The project is modeled after the architecture used to deliver customized user experiences in large-scale, multi-tenant applications, such as a satellite internet service with various providers and customer plans.

The app allows for real-time UI and feature updates without requiring an App Store submission, all managed through a Firebase backend. It showcases advanced concepts like feature gating, multi-context user support (e.g., personal vs. business plans), offline caching, and a decoupled, component-based UI architecture.

## Key Features

* **Dynamic UI Rendering:** The entire UI, including the theme color, feature lists, and tab bar, is dynamically built based on the configuration fetched from the server.
* **Client Context System:** The app's appearance and available features change based on the user's context (e.g., different providers and plan types).
* **Merged Contexts:** The app can intelligently merge configurations for users who belong to multiple groups (e.g., a user with both personal and business plans).
* **Feature Gating:** Features can be enabled or disabled remotely. The UI is built from a list of feature flags, and individual feature views are rendered dynamically.
* **Offline Caching:** The app uses Firebase's built-in persistence to cache the last known configuration, ensuring it is fully functional even without an internet connection.
* **Type-Safe & Forward-Compatible:** The app uses a custom `Codable` Swift `enum` to safely parse new or unknown features from the backend without crashing, while logging them to Analytics for review.
* **Component-Based Architecture:** Each feature is built as a separate, reusable SwiftUI view, managed by a `ViewFactory` for a clean and scalable codebase.
* **Debug Tools:** The app includes a debug picker to easily simulate different user contexts for testing and development.

## Tech Stack

* **UI:** SwiftUI
* **Backend & Services:**
    * **Firebase Remote Config:** For managing all configuration parameters and conditional values.
    * **Firebase Authentication:** For anonymous sign-in to satisfy security rules.
    * **Google Analytics for Firebase:** For setting User Properties that drive conditional configurations.
* **Architecture:** Model-View-ViewModel (MVVM)
* **Language:** Swift

## Setup

1.  Clone the repository.
2.  Create a new project in the [Firebase Console](https://console.firebase.google.com/).
3.  Add an iOS app to your Firebase project and download the `GoogleService-Info.plist` file. Place this file in the `ConfigHub/` subfolder and add it to your `.gitignore`.
4.  In the Firebase Console, enable **Anonymous Authentication**.
5.  In the **Remote Config** section, create the necessary parameters and conditional values.
6.  Open the project in Xcode, which will automatically resolve the Swift Package Manager dependencies.
7.  Build and run the app.
