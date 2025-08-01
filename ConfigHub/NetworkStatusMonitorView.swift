//
//  NetworkStatusMonitorView.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/30/25.
//
import SwiftUI
struct StatusRowView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
                .frame(width: 30)
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct NetworkStatusMonitorView: View {
    let contexts: [String]
    private var isComboUser: Bool { contexts.count > 1 }

    var body: some View {
        List {
            if isComboUser {
                Section(header: Text("Personal Network")) {
                    StatusRowView(title: "Latency", value: "52 ms", icon: "timer", color: .blue)
                    StatusRowView(title: "Download", value: "98.5 Mbps", icon: "arrow.down.circle", color: .green)
                }
                Section(header: Text("Business Network (Priority)")) {
                    StatusRowView(title: "Latency", value: "38 ms", icon: "timer", color: .blue)
                    StatusRowView(title: "Download", value: "250.1 Mbps", icon: "arrow.down.circle", color: .green)
                }
            } else {
                Section(header: Text("Live Status")) {
                    StatusRowView(title: "Latency", value: "52 ms", icon: "timer", color: .blue)
                    StatusRowView(title: "Download", value: "98.5 Mbps", icon: "arrow.down.circle", color: .green)
                    StatusRowView(title: "Upload", value: "12.3 Mbps", icon: "arrow.up.circle", color: .orange)
                }
            }
            
            Section {
                Button("Run Speed Test") {}
            }
        }
        .navigationTitle("Network Status")
    }
}
