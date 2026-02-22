import Foundation

/// Loads vehicle make/model data from the bundled VehicleCatalog.json resource.
/// To update the catalog, edit `Fleet/Resources/VehicleCatalog.json` directly.
enum VehicleCatalog {

    /// All makes sorted alphabetically.
    static let makes: [String] = catalog.keys.sorted()

    /// Returns the models for a given make, sorted alphabetically.
    static func models(for make: String) -> [String] {
        (catalog[make] ?? []).sorted()
    }

    /// Year range available for selection (descending so newest appears first).
    static let years: [Int] = Array((2005...2025).reversed())

    // MARK: - Private

    private static let catalog: [String: [String]] = {
        guard let url = Bundle.main.url(forResource: "VehicleCatalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([CatalogEntry].self, from: data) else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: entries.map { ($0.make, $0.models) })
    }()
}

private struct CatalogEntry: Decodable {
    let make: String
    let models: [String]
}
