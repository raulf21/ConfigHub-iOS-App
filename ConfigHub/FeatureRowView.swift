//
//  FeatureRowView.swift
//  ConfigHub
//
//  Created by Raul Flores on 8/1/25.
//
import SwiftUI

struct FeatureRowView: View {
    let feature: Feature

    var body: some View {
        HStack(spacing: 12) {
            icon(for: feature)
                .imageScale(.large)
                .foregroundColor(Color(UIColor.label))                 // semantic label color

            VStack(alignment: .leading, spacing: 2) {
                Text(title(for: feature))
                    .font(.body.weight(.semibold))
                    .foregroundColor(Color(UIColor.label))             // force readable text
                Text(subtitle(for: feature))
                    .font(.caption)
                    .foregroundColor(Color(UIColor.secondaryLabel))    // semantic secondary
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(Color(UIColor.tertiaryLabel))         // semantic tertiary
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))          // solid, adaptive card
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(UIColor.separator), lineWidth: 0.5)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous)) // full tap target
    }

    // MARK: - Titles & icons

    private func title(for feature: Feature) -> String {
        switch feature {
        case .billingPortal:          return "Billing Portal"
        case .multiUserManagement:    return "Multi User Management"
        case .networkStatusMonitor:   return "Network Status Monitor"
        case .satelliteCoverageMap:   return "Satellite Coverage Map"
        case .supportChat:            return "Support Chat"
        case .viewDataUsage:          return "View Data Usage"
        case .unknown:                return "Unknown"
        }
    }

    private func subtitle(for feature: Feature) -> String {
        switch feature {
        case .billingPortal:          return "Manage payments and invoices"
        case .multiUserManagement:    return "Invite and manage team members"
        case .networkStatusMonitor:   return "Signal quality and outages"
        case .satelliteCoverageMap:   return "Coverage by region"
        case .supportChat:            return "Get help from support"
        case .viewDataUsage:          return "Usage by day/month"
        case .unknown:                return ""
        }
    }

    private func icon(for feature: Feature) -> Image {
        switch feature {
        case .billingPortal:          return Image(systemName: "creditcard.fill")
        case .multiUserManagement:    return Image(systemName: "person.3.fill")
        case .networkStatusMonitor:   return Image(systemName: "antenna.radiowaves.left.and.right")
        case .satelliteCoverageMap:   return Image(systemName: "map.fill")
        case .supportChat:            return Image(systemName: "message.fill")
        case .viewDataUsage:          return Image(systemName: "chart.pie.fill")
        case .unknown:                return Image(systemName: "star.fill")
        }
    }
}
