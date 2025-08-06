//
//  ConfigHubApp.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/29/25.
//

import SwiftUI
import Firebase
import FirebaseRemoteConfig

@main
struct ConfigHubApp: App {
  init() {
    FirebaseApp.configure()

    let rc = RemoteConfig.remoteConfig()
    let settings = RemoteConfigSettings()
    #if DEBUG
    settings.minimumFetchInterval = 0         // always fetch in Debug
    #else
    settings.minimumFetchInterval = 86400     // 24h in Release
    #endif
    settings.fetchTimeout = 2                 // lean LLD
    rc.configSettings = settings
  }

  var body: some Scene {
    WindowGroup { ContentView() }
  }
}
