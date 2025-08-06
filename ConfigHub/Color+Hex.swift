//
//  Color+Hex.swift
//  ConfigHub
//
//  Created by Raul Flores on 8/4/25.
//
import SwiftUI
import UIKit

public extension Color {
    /// Initialize a Color from a hex string like "#RRGGBB" (case-insensitive).
    init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        let r = Double((v >> 16) & 0xFF) / 255.0
        let g = Double((v >> 8) & 0xFF) / 255.0
        let b = Double(v & 0xFF) / 255.0
        self = Color(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }

    /// Simple contrast helper: returns black/white text color that should be readable over the hex background.
    static func textColor(forHexBackground hex: String) -> Color {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return .white }
        let r = Double((v >> 16) & 0xFF) / 255.0
        let g = Double((v >> 8) & 0xFF) / 255.0
        let b = Double(v & 0xFF) / 255.0
        let luminance = 0.2126*r + 0.7152*g + 0.0722*b
        return luminance < 0.6 ? .white : .black
    }
    static func isDarkBackground(hex: String) -> Bool {
            var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            if s.hasPrefix("#") { s.removeFirst() }
            guard s.count == 6, let v = UInt32(s, radix: 16) else { return false }
            let r = Double((v >> 16) & 0xFF) / 255.0
            let g = Double((v >> 8) & 0xFF) / 255.0
            let b = Double(v & 0xFF) / 255.0
            let luminance = 0.2126*r + 0.7152*g + 0.0722*b
            return luminance < 0.6   // true = dark bg (so use light text)
        }
}

public extension UIColor {
    /// Initialize a UIColor from a hex string like "#RRGGBB".
    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        let r = CGFloat((v >> 16) & 0xFF) / 255.0
        let g = CGFloat((v >> 8) & 0xFF) / 255.0
        let b = CGFloat(v & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
