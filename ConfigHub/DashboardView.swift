//
//  DashboardView.swift
//  ConfigHub
//
//  Created by Raul Flores on 8/1/25.
//
import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: ConfigurationViewModel
    @Binding var selectedContext: String
    @Binding var activeContexts: [String]

    private let allContexts = ["auralink_personal", "auralink_business", "auralink_combo", "zenithsat_personal", "zenithsat_business", "zenithsat_combo"]

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Client Context (Debug)")) {
                    Picker("Select Context", selection: $selectedContext) {
                        ForEach(allContexts, id: \.self) { Text($0) }
                    }.pickerStyle(.menu)
                }
                Section(header: Text(viewModel.finalConfig.displayName)) {
                    HStack {
                        Image(systemName: "speedometer")
                        Text("Data Limit: \(viewModel.finalConfig.dataLimit) GB")
                    }
                    if viewModel.finalConfig.hasPrioritySupport {
                        HStack {
                            Image(systemName: "star.fill").foregroundColor(.yellow)
                            Text("Priority Support Enabled")
                        }
                    }
                }
                Section(header: Text("Features")) {
                    ForEach(viewModel.finalConfig.features, id: \.self) { feature in
                        NavigationLink(destination: FeatureViewFactory.detailView(for: feature, contexts: activeContexts)) {
                            FeatureRowView(feature: feature)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Dashboard")
            .background(viewModel.finalConfig.themeColor.toColor())
            .scrollContentBackground(.hidden)
        }
    }
}
