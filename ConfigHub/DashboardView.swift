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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                #if DEBUG
                // Debug-only: show the current context so you can verify targeting
                HStack {
                    Text("Selected Context")
                    Spacer()
                    Text(selectedContext).foregroundStyle(.secondary)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                #endif

                // Plan summary card
                VStack(alignment: .leading, spacing: 12) {
                    Text(viewModel.finalConfig.displayName.uppercased())
                        .font(.caption.weight(.bold))
                        .opacity(0.75)

                    HStack {
                        Label("Data Limit: \(viewModel.finalConfig.dataLimit) GB",
                              systemImage: "timer")
                        Spacer()
                    }

                    Divider()

                    if viewModel.finalConfig.hasPrioritySupport {
                        Label("Priority Support Enabled", systemImage: "star.fill")
                    } else {
                        Label("Priority Support", systemImage: "star")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                // Features section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Features")
                            .font(.caption.weight(.bold))
                            .opacity(0.75)
                        Spacer()
                        if viewModel.isLimitedMode {
                            Label("Limited mode", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if viewModel.isLimitedMode {
                        // Show non-tappable, dimmed rows while Limited Mode is active
                        ForEach(viewModel.finalConfig.features, id: \.self) { feature in
                            FeatureRowView(feature: feature)
                                .opacity(0.5)
                                .overlay(
                                    HStack { Spacer()
                                        Image(systemName: "lock.fill")
                                            .foregroundStyle(.tertiary)
                                            .padding(.trailing, 12)
                                    }
                                )
                        }
                    } else {
                        // Normal navigation to feature detail
                        ForEach(viewModel.finalConfig.features, id: \.self) { feature in
                            NavigationLink(
                                destination: FeatureViewFactory.detailView(for: feature, contexts: activeContexts)
                            ) {
                                FeatureRowView(feature: feature)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        // Subtle, readable background: system background + light theme tint
        .background(
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                (Color(hex: viewModel.finalConfig.themeColor) ?? .purple)
                    .opacity(0.18) // adjust 0.12–0.22 to taste
                    .ignoresSafeArea()
            }
        )
        .scrollContentBackground(.hidden)
    }
}
