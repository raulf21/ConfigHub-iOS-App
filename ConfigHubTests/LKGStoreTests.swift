//
//  LKGStoreTests.swift
//  ConfigHub
//
//  Created by Raul Flores on 8/6/25.
//
import XCTest
@testable import ConfigHub

final class LKGStoreTests: XCTestCase {
    func testSaveLoadReset() {
        let dict: [String: Any] = [
            "displayName": "TEST",
            "themeColor": "#112233",
            "dataLimit": 10,
            "hasPrioritySupport": true,
            "features": ["billing_portal"],
            "meta_config_version": "v1",
            "meta_ttl_seconds": 60,
            "limitedMode": false
        ]
        XCTAssertTrue(LKGStore.shared.save(dict))
        let loaded = LKGStore.shared.load()
        XCTAssertEqual(loaded?["displayName"] as? String, "TEST")
        LKGStore.shared.reset()
        XCTAssertNil(LKGStore.shared.load())
    }
}

