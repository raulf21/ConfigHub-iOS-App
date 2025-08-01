//
//  DataUsageView.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/30/25.
//
import SwiftUI

struct DataUsageView: View {
    let contexts: [String]
    private var isComboUser: Bool { contexts.count > 1 }
    
    var body: some View {
        List {
            if isComboUser {
                Section(header: Text("Personal Plan Usage")) {
                    UsageProgressView(used: 68.5, limit: 150.0)
                }
                Section(header: Text("Business Plan Usage")) {
                    UsageProgressView(used: 250.0, limit: 750.0)
                }
            } else {
                Section(header: Text("Current Cycle Usage")) {
                    UsageProgressView(used: 68.5, limit: 150.0)
                }
            }
        }.navigationTitle("Data Usage")
    }
}

struct UsageProgressView: View {
    let used: Double, limit: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ProgressView(value: used, total: limit) {
                Text("Data Usage")
            } currentValueLabel: {
                Text("\(String(format: "%.1f", used)) GB")
            }
            .progressViewStyle(.linear)
            Text("You have used \(String(format: "%.0f", (used / limit) * 100))% of your \(String(format: "%.0f", limit)) GB monthly limit.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical)
    }
}
