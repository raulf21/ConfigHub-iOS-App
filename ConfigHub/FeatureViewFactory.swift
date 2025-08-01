//
//  FeatureViewFactory.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/30/25.
//
import SwiftUI

struct FeatureViewFactory {
    @ViewBuilder
    static func rowView(for feature: Feature) -> some View {
        FeatureRowView(feature: feature)
    }
    
    @ViewBuilder
    static func detailView(for feature: Feature, contexts: [String]) -> some View {
        switch feature {
        case .viewDataUsage:
            DataUsageView(contexts: contexts)
        case .billingPortal:
            BillingPortalView(contexts: contexts)
        case .multiUserManagement:
            MultiUserManagementView(contexts: contexts)
        case .satelliteCoverageMap:
            SatelliteCoverageMapView()
        case .networkStatusMonitor:
            NetworkStatusMonitorView(contexts: contexts)
        case .supportChat:
            SupportChatView(contexts: contexts)
        case .unknown:
            EmptyView()
        }
    }
}
