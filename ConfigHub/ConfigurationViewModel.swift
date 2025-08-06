//
//  ConfigurationViewModel.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/29/25.
//
import Foundation
import Combine
import FirebaseRemoteConfig
import FirebaseAnalytics

// Final configuration applied to the UI
struct FinalConfig {
    var displayName: String = "Standard User"
    var themeColor: String = "#CCCCCC"
    var dataLimit: Int = 0
    var hasPrioritySupport: Bool = false
    var features: [Feature] = []
}

final class ConfigurationViewModel: ObservableObject {
    // UI state
    @Published var finalConfig: FinalConfig = FinalConfig()
    @Published var tabFeatures: [Feature] = []

    // Observability / debug
    @Published var isLimitedMode: Bool = false           // kill_switch or unionKill
    @Published var metaVersion: String = ""              // from RC
    @Published var isStale: Bool = false                 // TTL expired vs LKG timestamp
    @Published var ttlSecondsRemaining: Int = 0          // seconds until TTL == 0

    private let remoteConfig = RemoteConfig.remoteConfig()

    // Load LKG at startup so the UI has data even if offline
    init() {
        if loadFromLKG() {
            // compute freshness from saved TTL + file timestamp
            refreshFreshnessFromLKG()
            print("[LKG] Loaded cached config at start.")
        } else {
            print("[LKG] No cache yet; using defaults.")
        }
    }

    /// contexts: e.g., ["auralink_personal"] or ["auralink_business","auralink_personal"]
    func loadConfig(forContexts contexts: [String]) {
        Task { @MainActor in
            guard !contexts.isEmpty else { return }

            // Theme comes from top tier (Business > Personal)
            let themeContext = contexts.first(where: { $0.localizedCaseInsensitiveContains("_business") })
                               ?? contexts[0]

            // 1) Fetch theme snapshot first (for visuals)
            let themeSnap = await fetchSnapshot(for: themeContext)

            // 2) Union features by fetching each context sequentially
            var union = Set<Feature>()
            var unionKill = false
            for ctx in contexts {
                let snap = await fetchSnapshot(for: ctx)
                union.formUnion(snap.features)
                unionKill = unionKill || snap.killSwitch
            }

            // 3) Build final config with kill-switch handling
            var cfg = FinalConfig()
            if unionKill || themeSnap.killSwitch {
                cfg = FinalConfig() // safe defaults
            } else {
                cfg.displayName = themeSnap.displayName
                cfg.themeColor = themeSnap.themeColor
                cfg.dataLimit = themeSnap.dataLimit
                cfg.hasPrioritySupport = themeSnap.hasPrioritySupport
                cfg.features = Array(union).sorted { $0.rawValue < $1.rawValue }
            }

            // 4) Publish state
            self.isLimitedMode = (unionKill || themeSnap.killSwitch)
            self.metaVersion = themeSnap.metaVersion
            self.finalConfig = cfg
            self.tabFeatures = cfg.features

            // 5) Persist LKG for offline and mark as fresh
            saveToLKG(cfg: cfg, metaVersion: themeSnap.metaVersion, ttlSeconds: themeSnap.ttlSeconds)
            self.isStale = false
            self.ttlSecondsRemaining = themeSnap.ttlSeconds

            // 6) Minimal analytics
            self.logEvent("rc_activation_success", ["value": 1, "meta_version": self.metaVersion])
            if self.isLimitedMode {
                self.logEvent("rc_killswitch_active", ["value": 1])
            }
        }
    }

    // MARK: - RC snapshot for a single context

    private struct RCSnapshot {
        var displayName: String = "Standard User"
        var themeColor: String = "#CCCCCC"
        var dataLimit: Int = 0
        var hasPrioritySupport: Bool = false
        var killSwitch: Bool = false
        var features: [Feature] = []
        var metaVersion: String = ""
        var ttlSeconds: Int = 86400
    }

    private func fetchSnapshot(for context: String) async -> RCSnapshot {
        // Set user property so RC conditions match this context
        Analytics.setUserProperty(context, forName: "provider_plan_type")
        print("[RC] set user property =", context)

        // Fetch & activate
        await withCheckedContinuation { cont in
            let t0 = Date()
            remoteConfig.fetchAndActivate { status, error in
                let ms = Int(Date().timeIntervalSince(t0) * 1000)
                print("[RC] fetch status =", status.rawValue, "error =", error as Any, "latency_ms=", ms)
                Analytics.logEvent("rc_fetch_latency_ms", parameters: ["value": ms])
                cont.resume()
            }
        }

        var snap = RCSnapshot()

        // Strings
        let display = remoteConfig["plan_displayName"].stringValue
        if !display.isEmpty { snap.displayName = display }

        let color = remoteConfig["plan_themeColor"].stringValue
        if !color.isEmpty { snap.themeColor = color }

        // Numbers / bools
        snap.dataLimit = remoteConfig["plan_data_limit"].numberValue.intValue
        snap.hasPrioritySupport = remoteConfig["plan_priority_support"].boolValue
        snap.killSwitch = remoteConfig["kill_switch"].boolValue

        // Meta
        let mv = remoteConfig["meta_config_version"].stringValue
        if !mv.isEmpty { snap.metaVersion = mv }
        snap.ttlSeconds = remoteConfig["meta_ttl_seconds"].numberValue.intValue

        // Feature list (JSON array string)
        let jsonStr = remoteConfig["plan_feature_list"].stringValue
        if let data = jsonStr.data(using: .utf8) {
            if let decoded = try? JSONDecoder().decode([Feature].self, from: data) {
                snap.features = decoded
            } else if let arr = (try? JSONSerialization.jsonObject(with: data)) as? [String] {
                snap.features = arr.compactMap { Feature(rawValue: $0) }
            }
        }

        // Basic validation (lean)
        if !isValidHex(snap.themeColor) {
            snap.themeColor = "#CCCCCC"
        }
        print("[RC] resolved name =", snap.displayName, "color =", snap.themeColor)
        return snap
    }

    // MARK: - Validation

    private func isValidHex(_ s: String) -> Bool {
        s.range(of: "^#([0-9A-Fa-f]{6})$", options: .regularExpression) != nil
    }

    // MARK: - LKG integration

    private func saveToLKG(cfg: FinalConfig, metaVersion: String, ttlSeconds: Int) {
        let dict: [String: Any] = [
            "displayName": cfg.displayName,
            "themeColor": cfg.themeColor,
            "dataLimit": cfg.dataLimit,
            "hasPrioritySupport": cfg.hasPrioritySupport,
            "features": cfg.features.map { $0.rawValue },
            "meta_config_version": metaVersion,
            "meta_ttl_seconds": ttlSeconds,
            "limitedMode": self.isLimitedMode
        ]
        let ok = LKGStore.shared.save(dict)
        print(ok ? "[LKG] Saved." : "[LKG] Save failed.")
    }

    @discardableResult
    private func loadFromLKG() -> Bool {
        guard let dict = LKGStore.shared.load() else { return false }
        var cfg = FinalConfig()
        cfg.displayName = (dict["displayName"] as? String) ?? cfg.displayName
        cfg.themeColor = (dict["themeColor"] as? String) ?? cfg.themeColor
        cfg.dataLimit = (dict["dataLimit"] as? Int) ?? cfg.dataLimit
        cfg.hasPrioritySupport = (dict["hasPrioritySupport"] as? Bool) ?? cfg.hasPrioritySupport
        if let f = dict["features"] as? [String] {
            cfg.features = f.compactMap { Feature(rawValue: $0) }.sorted { $0.rawValue < $1.rawValue }
        }
        self.finalConfig = cfg
        self.tabFeatures = cfg.features
        self.metaVersion = (dict["meta_config_version"] as? String) ?? ""
        self.isLimitedMode = (dict["limitedMode"] as? Bool) ?? false
        return true
    }

    private func refreshFreshnessFromLKG() {
        // derive isStale/ttlSecondsRemaining from saved TTL + file timestamp
        let ttl = (LKGStore.shared.load()?["meta_ttl_seconds"] as? Int) ?? 86400
        if let last = LKGStore.shared.lastModified {
            let age = Int(Date().timeIntervalSince(last))
            self.ttlSecondsRemaining = max(0, ttl - age)
            self.isStale = age > ttl
        } else {
            self.ttlSecondsRemaining = ttl
            self.isStale = false
        }
    }

    // MARK: - Analytics

    private func logEvent(_ name: String, _ params: [String: Any] = [:]) {
        Analytics.logEvent(name, parameters: params)
    }
}
