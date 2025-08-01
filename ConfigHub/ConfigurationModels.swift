//
//  ConfigurationModels.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/29/25.
//

import Foundation

/// This struct matches a document in 'roles' collection
struct Role: Codable {
    let configName: String
}

// This struct matches a document in 'configuration' collection
struct AppConfiguration: Codable {
    let themeColor: String
    let showDashboard: Bool
    let showAdvancedAnalytics: Bool
    let maxTeamMembers: Int
    let enablePrioritySupport: Bool? //Optional, since it's not every tier
}
