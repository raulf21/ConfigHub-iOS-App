//
//  ContentView.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/29/25.
//
//
//  ContentView.swift
//  ConfigHub
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ConfigurationViewModel()

    // Only single, real contexts (no “combo” in RC)
    private let contexts = [
        "auralink_personal",
        "auralink_business",
        "zenithsat_personal",
        "zenithsat_business"
    ]

    @State private var selectedContext = "zenithsat_business"
    @State private var includeBothTiers = true        // client-side union toggle
    @State private var contextsToLoad: [String] = ["zenithsat_business"]
    @State private var showDebug = false

    var body: some View {
        // Compute theme + contrasting color once
        let themeHex  = viewModel.finalConfig.themeColor
        let themeBG   = Color(hex: themeHex) ?? .purple
        let themeText = Color.textColor(forHexBackground: themeHex)   // CONTRAST

        ZStack {
            // Main app tabs
            TabView {
                // *** KEY CHANGE: Wrap dashboard in NavigationStack ***
                NavigationStack {
                    DashboardView(
                        viewModel: viewModel,
                        selectedContext: $selectedContext,
                        activeContexts: $contextsToLoad
                    )
                    .navigationTitle("Dashboard")
                }
                .tabItem { Label("Dashboard", systemImage: "house.fill") }

                // Other feature tabs (already inside NavigationStack)
                ForEach(viewModel.tabFeatures.prefix(4), id: \.self) { feature in
                    NavigationStack {
                        FeatureViewFactory.detailView(for: feature, contexts: contextsToLoad)
                            .navigationTitle(feature.shortName)
                    }
                    .tabItem { tabLabel(for: feature) }
                }

                if viewModel.tabFeatures.count > 4 {
                    NavigationStack {
                        List {
                            ForEach(viewModel.tabFeatures.dropFirst(4), id: \.self) { feature in
                                NavigationLink(
                                    destination: FeatureViewFactory.detailView(for: feature, contexts: contextsToLoad)
                                        .navigationTitle(feature.shortName)
                                ) { FeatureRowView(feature: feature) }
                            }
                        }
                        .listStyle(.insetGrouped)
                        .navigationTitle("More Features")
                        .scrollContentBackground(.hidden)
                    }
                    .tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
                }
            }
            // Use CONTRASTING tint so labels/icons stay readable
            .tint(themeText)

            // Banners (top) — contrasting text, subtle theme-tinted background
            VStack(spacing: 8) {
                if viewModel.isLimitedMode {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Limited mode enabled")
                        Spacer()
                        Text(viewModel.metaVersion.isEmpty ? "-" : viewModel.metaVersion)
                            .font(.caption)
                            .opacity(0.8)
                    }
                    .padding(10)
                    .foregroundColor(themeText)
                    .background(themeBG.opacity(0.28), in: Capsule())
                }

                if viewModel.isStale {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Stale config")
                        Spacer()
                        Text("TTL 0s").font(.caption).opacity(0.8)
                    }
                    .padding(10)
                    .foregroundColor(themeText)
                    .background(themeBG.opacity(0.28), in: Capsule())
                } else {
                    #if DEBUG
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                        Text("Fresh (\(viewModel.ttlSecondsRemaining)s left)")
                        Spacer()
                        Text(viewModel.metaVersion.isEmpty ? "-" : viewModel.metaVersion)
                            .font(.caption).opacity(0.8)
                    }
                    .padding(10)
                    .foregroundColor(themeText)
                    .background(themeBG.opacity(0.28), in: Capsule())
                    #endif
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .allowsHitTesting(false)

            // Debug button (Debug builds only)
            #if DEBUG
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showDebug = true
                    } label: {
                        Image(systemName: "wrench.and.screwdriver")
                            .padding(10)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                Spacer()
            }
            .padding()
            #endif
        }
        .onAppear { reload() }
        .onChange(of: selectedContext) { _ in reload() }
        .onChange(of: includeBothTiers) { _ in reload() }
        .sheet(isPresented: $showDebug) {
            DebugControlsView(
                vm: viewModel,
                contexts: contexts,
                selectedContext: $selectedContext,
                includeBothTiers: $includeBothTiers,
                onApply: { reload() }
            )
        }
    }

    private func reload() {
        contextsToLoad = computedContexts(from: selectedContext, includeBothTiers: includeBothTiers)
        viewModel.loadConfig(forContexts: contextsToLoad)
    }

    private func computedContexts(from ctx: String, includeBothTiers: Bool) -> [String] {
        guard includeBothTiers else { return [ctx] }
        if ctx.hasPrefix("auralink") {
            return ctx.contains("_business")
                ? ["auralink_business", "auralink_personal"]
                : ["auralink_personal", "auralink_business"]
        } else if ctx.hasPrefix("zenithsat") {
            return ctx.contains("_business")
                ? ["zenithsat_business", "zenithsat_personal"]
                : ["zenithsat_personal", "zenithsat_business"]
        }
        return [ctx]
    }

    @ViewBuilder
    private func tabLabel(for feature: Feature) -> some View {
        let name = feature.shortName
        switch feature {
        case .viewDataUsage:        Label(name, systemImage: "chart.pie.fill")
        case .billingPortal:        Label(name, systemImage: "creditcard.fill")
        case .multiUserManagement:  Label(name, systemImage: "person.3.fill")
        case .satelliteCoverageMap: Label(name, systemImage: "map.fill")
        case .networkStatusMonitor: Label(name, systemImage: "antenna.radiowaves.left.and.right")
        case .supportChat:          Label(name, systemImage: "message.fill")
        case .unknown:              Label(name, systemImage: "star.fill")
        }
    }
}

// MARK: - Debug sheet

struct DebugControlsView: View {
    @ObservedObject var vm: ConfigurationViewModel
    let contexts: [String]
    @Binding var selectedContext: String
    @Binding var includeBothTiers: Bool
    var onApply: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Context") {
                    Picker("Context", selection: $selectedContext) {
                        ForEach(contexts, id: \.self) { Text($0).tag($0) }
                    }
                    Toggle("Load both tiers for this partner", isOn: $includeBothTiers)
                }

                Section("Info") {
                    HStack { Text("Meta Version"); Spacer(); Text(vm.metaVersion.isEmpty ? "-" : vm.metaVersion) }
                    HStack { Text("Limited Mode"); Spacer(); Text(vm.isLimitedMode ? "Yes" : "No") }
                    HStack { Text("Stale"); Spacer(); Text(vm.isStale ? "Yes" : "No") }
                    HStack { Text("TTL remaining"); Spacer(); Text("\(vm.ttlSecondsRemaining)s") }
                }

                Section("Actions") {
                    Button("Fetch Now") { onApply() }
                    Button("Reset LKG") {
                        LKGStore.shared.reset()
                        onApply()
                    }
                }
            }
            .navigationTitle("Debug Controls")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Apply") { onApply() } }
            }
        }
    }
}
