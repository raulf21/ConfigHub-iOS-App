
import Foundation

/// Lean file-backed cache for the "Last-Known-Good" configuration.
/// Stores a small JSON dictionary on disk and exposes simple load/save/reset APIs.
final class LKGStore {
    static let shared = LKGStore()
    private let queue = DispatchQueue(label: "LKGStore.queue", qos: .utility)
    
    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = dir.appendingPathComponent("ConfigHub", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        return appDir.appendingPathComponent("remote_config_lkg.json")
    }()
    
    /// Loads the cached dictionary if present; otherwise returns nil.
    func load() -> [String: Any]? {
        var result: [String: Any]?
        queue.sync {
            guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
            guard let data = try? Data(contentsOf: fileURL),
                  let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
            result = obj
        }
        return result
    }
    
    /// Saves the given dictionary to disk. Keys should be simple JSON-encodable values.
    @discardableResult
    func save(_ dict: [String: Any]) -> Bool {
        var ok = false
        queue.sync {
            guard JSONSerialization.isValidJSONObject(dict),
                  let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]) else { return }
            do {
                try data.write(to: fileURL, options: [.atomic])
                ok = true
            } catch {
                ok = false
            }
        }
        return ok
    }
    
    /// Deletes the LKG file, if any.
    func reset() {
        queue.sync {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    /// Timestamp of the LKG file (modification date), if it exists.
    var lastModified: Date? {
        var date: Date?
        queue.sync {
            if let attrs = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
               let m = attrs[.modificationDate] as? Date {
                date = m
            }
        }
        return date
    }
}
