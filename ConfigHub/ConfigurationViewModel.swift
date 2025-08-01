//
//  ConfigurationViewModel.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/29/25.
//
import Foundation
import FirebaseRemoteConfig
import FirebaseAuth
import FirebaseAnalytics

struct FinalConfig {
    var displayName: String = "Standard User"
    var themeColor: String = "#CCCCCC"
    var dataLimit: Int = 0
    var hasPrioritySupport: Bool = false
    var features: [Feature] = []
}

class ConfigurationViewModel: ObservableObject {
    @Published var finalConfig = FinalConfig()
    @Published var tabFeatures: [Feature] = []
    private var remoteConfig: RemoteConfig

    init() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        self.remoteConfig.configSettings = settings
        self.remoteConfig.setDefaults([
            "plan_displayName": "Standard User" as NSObject,
            "plan_themeColor": "#CCCCCC" as NSObject,
            "plan_data_limit": 50 as NSObject,
            "plan_priority_support": false as NSObject,
            "plan_feature_list": "[]" as NSObject
        ])
    }

    func loadConfig(forContexts contexts: [String]) {
        var mergedFeatures = Set<Feature>()
        let dispatchGroup = DispatchGroup()
        contexts.forEach { context in
            dispatchGroup.enter()
            Analytics.setUserProperty(context, forName: "provider_plan_type")
            self.remoteConfig.fetchAndActivate { (status, error) in
                if status != .error {
                    let featureListData = self.remoteConfig["plan_feature_list"].dataValue
                    if let features = try? JSONDecoder().decode([Feature].self, from: featureListData) {
                        mergedFeatures.formUnion(features)
                    }
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            var newConfig = FinalConfig()
            newConfig.displayName = self.remoteConfig["plan_displayName"].stringValue ?? "Default"
            newConfig.themeColor = self.remoteConfig["plan_themeColor"].stringValue ?? "#CCCCCC"
            newConfig.dataLimit = self.remoteConfig["plan_data_limit"].numberValue.intValue
            newConfig.hasPrioritySupport = self.remoteConfig["plan_priority_support"].boolValue
            let sortedFeatures = Array(mergedFeatures).sorted { $0.rawValue < $1.rawValue }
            newConfig.features = sortedFeatures
            self.finalConfig = newConfig
            self.tabFeatures = sortedFeatures
        }
    }
}
