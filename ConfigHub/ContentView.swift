//
//  ContentView.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/29/25.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ConfigurationViewModel()
    @State private var selectedContext = "auralink_personal"
    @State private var contextsToLoad: [String] = ["auralink_personal"]

    // Add "zenithsat_combo" to the list of testable contexts
    private let clientContexts = ["auralink_personal", "auralink_business", "auralink_combo", "zenithsat_personal", "zenithsat_business", "zenithsat_combo"]

    var body: some View {
        TabView {
            DashboardView(viewModel: viewModel, selectedContext: $selectedContext, activeContexts: $contextsToLoad)
                .tabItem { Label("Dashboard", systemImage: "house.fill") }

            ForEach(viewModel.tabFeatures.prefix(4), id: \.self) { feature in
                NavigationStack {
                    FeatureViewFactory.detailView(for: feature, contexts: contextsToLoad)
                }.tabItem { tabLabel(for: feature) }
            }

            if viewModel.tabFeatures.count > 4 {
                NavigationStack {
                    List {
                        ForEach(viewModel.tabFeatures.dropFirst(4), id: \.self) { feature in
                            NavigationLink(destination: FeatureViewFactory.detailView(for: feature, contexts: contextsToLoad)) {
                                FeatureRowView(feature: feature)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .navigationTitle("More Features")
                }.tabItem { Label("More", systemImage: "ellipsis.circle.fill") }
            }
        }
        // This is the updated logic to handle both combo types
        .onChange(of: selectedContext) {
            let newContexts: [String]
            if selectedContext == "auralink_combo" {
                newContexts = ["auralink_personal", "auralink_business"]
            } else if selectedContext == "zenithsat_combo" {
                newContexts = ["zenithsat_personal", "zenithsat_business"]
            } else {
                newContexts = [selectedContext]
            }
            self.contextsToLoad = newContexts
            viewModel.loadConfig(forContexts: newContexts)
        }
        .onAppear {
            viewModel.loadConfig(forContexts: contextsToLoad)
        }
    }

    @ViewBuilder
    private func tabLabel(for feature: Feature) -> some View {
        let name = feature.shortName
        switch feature {
            case .viewDataUsage: Label(name, systemImage: "chart.pie.fill")
            case .billingPortal: Label(name, systemImage: "creditcard.fill")
            case .multiUserManagement: Label(name, systemImage: "person.3.fill")
            default: Label(name, systemImage: "star.fill")
        }
    }
}

// Keep the String to Color extension here
extension String {
    func toColor() -> Color {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        if ((cString.count) != 6) { return Color.gray }
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return Color(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}
