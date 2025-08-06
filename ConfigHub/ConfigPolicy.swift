//
//  ConfigPolicy.swift
//  ConfigHub
//
//  Created by Raul Flores on 8/5/25.
//

import Foundation

enum ConfigPolicy {
    /// Business > Personal theme precedence. Returns the chosen context for theme.
    static func themeContext(from contexts: [String]) -> String? {
        guard !contexts.isEmpty else { return nil }
        if let business = contexts.first(where: { $0.localizedCaseInsensitiveContains("_business") }) {
            return business
        }
        return contexts.first
    }

    /// Sorted union of features (by rawValue).
    static func unionFeatures(_ lists: [[Feature]]) -> [Feature] {
        var set = Set<Feature>()
        for l in lists { set.formUnion(l) }
        return set.sorted { $0.rawValue < $1.rawValue }
    }
}
