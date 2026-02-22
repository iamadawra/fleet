import SwiftData

enum ModelContainerConfig {
    /// Whether the container fell back to in-memory storage due to a persistence error.
    static private(set) var didFallBackToInMemory = false
    static private(set) var containerError: String?

    static func makeContainer() -> ModelContainer {
        let schema = Schema([Vehicle.self])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Log the error but do not crash. Fall back to an in-memory store so
            // the app remains usable (data will not persist across launches).
            print("[Fleet] Error: Failed to create persistent ModelContainer: \(error.localizedDescription). Falling back to in-memory storage.")
            didFallBackToInMemory = true
            containerError = error.localizedDescription

            let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [inMemoryConfig])
            } catch {
                // This should not happen but we still avoid fatalError
                print("[Fleet] Critical: Even in-memory ModelContainer failed: \(error.localizedDescription)")
                containerError = "Critical storage failure: \(error.localizedDescription)"
                // Last resort: attempt with default configuration
                return try! ModelContainer(for: schema)
            }
        }
    }
}
