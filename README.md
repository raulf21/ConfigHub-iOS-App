# ConfigHub: A Scalable Remote Configuration System for iOS

## Executive Summary

ConfigHub is a production-grade iOS application built with SwiftUI that demonstrates a robust, scalable remote configuration system. The project's architecture is modeled after the dynamic, multi-tenant systems required to serve customized user experiences for a satellite internet provider with distinct partners and customer tiers (e.g., personal, business, and combined plans).

This system allows for real-time UI and feature flag management via a Firebase backend, eliminating the need for App Store updates for most changes. It is architected to handle complex business logic, such as merged user contexts, while ensuring a seamless offline experience and forward compatibility with future features.

## App Demo

![App Demo](https://media.giphy.com/media/CKlzLlOEYqf3Tlur6G/giphy.gif)

## Architectural Decisions & Key Concepts

This project was built to solve several complex, real-world engineering challenges:

* **Server-Side Logic with Client-Side Fallbacks:** The primary architecture uses **Firebase Remote Config with Conditions** to manage complexity on the server. The client provides its context (via an Analytics User Property), and the server returns the precise configuration. This minimizes client-side logic and reduces the potential for bugs. For advanced cases like merged contexts, the client contains robust logic to fetch and intelligently combine multiple configurations.

* **Decoupled, Component-Based UI:** The UI is not monolithic. It is built dynamically using a `ViewFactory` that maps a type-safe `Feature` enum to specific, reusable SwiftUI views. This demonstrates true **feature gating** and makes the codebase incredibly easy to maintain and scale.

* **Type Safety & Forward Compatibility:** To prevent crashes from backend changes, the app uses a custom `Codable` Swift `enum` with an `.unknown` case. If the server sends a new feature the app doesn't recognize, it is safely decoded and ignored by the UI, while an analytics event is logged to alert the development team. This ensures high reliability.

* **Offline-First Approach:** The system is designed for users with intermittent connectivity. Both Firebase Remote Config and Firestore (in earlier iterations) are configured with on-disk persistence. The last successfully fetched configuration is automatically cached, ensuring the app remains fully functional when the user is offline.

* **Integrated Debug Tools:** The app includes a developer-only debug picker that allows for easy simulation of various user contexts, dramatically improving testing efficiency and accuracy.

## Features & Context Logic

The application serves a unique UI and feature set based on the user's context. The logic is designed to support both individual and combined (e.g., Personal + Business) plans.

| Context | Display Name | Theme Color | Data Limit (GB) | Priority Support | Key Features |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **AuraLink Personal** | AuraLink Personal | Blue (`#3498DB`) | 150 | No | `Usage`, `Billing`, `Support Chat`, `Map`, `Status` |
| **AuraLink Business** | AuraLink Business | Dark Blue (`#2C3E50`) | 750 | **Yes** | `Usage`, `Billing`, `Support Chat`, `Map`, `Status`, **`Team`** |
| **ZenithSat Personal** | ZenithSat Home | Green (`#2ECC71`) | 180 | No | `Usage`, `Billing`, `Support Chat`, `Map`, `Status` |
| **ZenithSat Business**| ZenithSat Pro | Purple (`#6C3483`) | 1500 | **Yes** | `Usage`, `Billing`, `Support Chat`, `Map`, `Status`, **`Team`** |
| **AuraLink Combo** | AuraLink P. + B. | Dark Blue | 750 (Max) | **Yes** | All features, including **`Team`** |
| **ZenithSat Combo** | ZenithSat P. + B. | Purple | 1500 | **Yes** | All features, including **`Team`** |

## Tech Stack

* **UI:** SwiftUI, MapKit
* **Architecture:** Model-View-ViewModel (MVVM), Component-Based Rendering
* **Backend & Services:**
    * **Firebase Remote Config:** For conditional parameter management.
    * **Firebase Authentication:** For anonymous sign-in and security rule enforcement.
    * **Google Analytics for Firebase:** For creating `User Properties` and `Audiences` to drive conditions.
* **Language:** Swift

## Setup

1.  Clone the repository.
2.  Create a project in the [Firebase Console](https://console.firebase.google.com/).
3.  Add an iOS app to your Firebase project, download `GoogleService-Info.plist`, and place it in the project's root source folder. Ensure this file is included in your `.gitignore`.
4.  In Firebase, enable **Anonymous Authentication**.
5.  In **Analytics > Custom Definitions**, create a User Property named `provider_plan_type`.
6.  In **Remote Config**, create the parameters and conditional values as outlined in the "Features & Context Logic" table.
7.  Open the project in Xcode, allow Swift Package Manager to resolve dependencies, and run the app.
