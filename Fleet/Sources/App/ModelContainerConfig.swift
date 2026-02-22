import SwiftData

enum ModelContainerConfig {
    static func makeContainer() -> ModelContainer {
        let schema = Schema([Vehicle.self])
        let config = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
