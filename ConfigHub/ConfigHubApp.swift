//
//  ConfigHubApp.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/29/25.
//

import SwiftUI
import FirebaseCore //Import Firebase
@main
struct ConfigHubApp: App {
    init() {
        FirebaseApp.configure() // Configure Firebase
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
