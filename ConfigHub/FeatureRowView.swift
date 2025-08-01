//
//  FeatureRowView.swift
//  ConfigHub
//
//  Created by Raul Flores on 8/1/25.
//
import SwiftUI

struct FeatureRowView: View {
    let feature: Feature
    
    private var iconName: String {
        switch feature {
        case .viewDataUsage: return "chart.pie.fill"
        case .billingPortal: return "creditcard.fill"
        case .multiUserManagement: return "person.3.fill"
        case .satelliteCoverageMap: return "map.fill"
        case .networkStatusMonitor: return "antenna.radiowaves.left.and.right"
        case .supportChat: return "message.fill"
        default: return "star.fill"
        }
    }
    
    private var iconColor: Color {
        switch feature {
        case .viewDataUsage: return .blue
        case .billingPortal: return .green
        case .multiUserManagement: return .purple
        case .satelliteCoverageMap: return .orange
        case .networkStatusMonitor: return .red
        case .supportChat: return .indigo
        default: return .gray
        }
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundColor(iconColor)
                .frame(width: 30)
            Text(feature.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
