//
//  Feature.swift
//  ConfigHub
//
//  Created by Raul Flores on 7/30/25.
//
import Foundation

enum Feature: String, Codable, CaseIterable, Hashable {
    case viewDataUsage = "view_data_usage"
    case billingPortal = "billing_portal"
    case multiUserManagement = "multi_user_management"
    case satelliteCoverageMap = "satellite_coverage_map"
    case networkStatusMonitor = "network_status_monitor"
    case supportChat = "support_chat"
    case unknown

    var shortName: String {
        switch self {
        case .viewDataUsage: return "Usage"
        case .billingPortal: return "Billing"
        case .multiUserManagement: return "Team"
        case .satelliteCoverageMap: return "Map"
        case .networkStatusMonitor: return "Status"
        case .supportChat: return "Chat"
        case .unknown: return "Unknown"
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Feature(rawValue: rawValue) ?? .unknown
    }
}
