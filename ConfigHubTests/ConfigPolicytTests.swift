//
//  ConfigPolicytTests.swift
//  ConfigHub
//
//  Created by Raul Flores on 8/5/25.
//
import XCTest
@testable import ConfigHub

final class ConfigPolicyTests: XCTestCase {

    func testThemePrecedence() {
        XCTAssertEqual(ConfigPolicy.themeContext(from: ["auralink_personal"]), "auralink_personal")
        XCTAssertEqual(ConfigPolicy.themeContext(from: ["auralink_business","auralink_personal"]), "auralink_business")
        XCTAssertEqual(ConfigPolicy.themeContext(from: ["zenithsat_personal","auralink_business"]), "auralink_business")
        XCTAssertNil(ConfigPolicy.themeContext(from: []))
    }

    func testUnionFeatures() {
        let a: [Feature] = [.viewDataUsage, .billingPortal, .supportChat]
        let b: [Feature] = [.multiUserManagement, .supportChat, .satelliteCoverageMap]
        let out = ConfigPolicy.unionFeatures([a, b])

        // Contains all unique items
        XCTAssertTrue(out.contains(.viewDataUsage))
        XCTAssertTrue(out.contains(.billingPortal))
        XCTAssertTrue(out.contains(.supportChat))
        XCTAssertTrue(out.contains(.multiUserManagement))
        XCTAssertTrue(out.contains(.satelliteCoverageMap))

        // No duplicates
        XCTAssertEqual(Set(out).count, out.count)
    }
}

