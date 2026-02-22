import Foundation
import FirebaseFirestore
import SwiftData

@MainActor
class FirestoreService: ObservableObject {
    private var db: Firestore? { AppDelegate.isFirebaseConfigured ? Firestore.firestore() : nil }
    private var listener: ListenerRegistration?
    private var userId: String?

    /// Published error from snapshot listener for views to observe
    @Published var listenerError: String?

    // MARK: - Listener Management

    func startListening(userId: String, modelContext: ModelContext) {
        guard let db else { return }
        stopListening()
        self.userId = userId

        listener = db.collection("users").document(userId).collection("vehicles")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                Task { @MainActor in
                    if let error {
                        self.listenerError = "Sync error: \(error.localizedDescription)"
                        return
                    }
                    guard let snapshot else {
                        self.listenerError = "Failed to receive data from server."
                        return
                    }
                    self.listenerError = nil
                    self.handleSnapshot(snapshot, modelContext: modelContext)
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        userId = nil
        listenerError = nil
    }

    // MARK: - CRUD Operations

    func uploadVehicle(_ vehicle: Vehicle) async throws {
        guard let db, let userId else { return }
        let data = vehicleToDict(vehicle)
        try await db.collection("users").document(userId).collection("vehicles")
            .document(vehicle.id.uuidString)
            .setData(data)
    }

    func deleteVehicle(_ vehicle: Vehicle) async throws {
        guard let db, let userId else { return }
        try await db.collection("users").document(userId).collection("vehicles")
            .document(vehicle.id.uuidString)
            .delete()
    }

    func syncAllLocalVehicles(modelContext: ModelContext) async throws {
        guard userId != nil else { return }
        let descriptor = FetchDescriptor<Vehicle>()
        let vehicles = try modelContext.fetch(descriptor)
        var errors: [String] = []
        for vehicle in vehicles {
            do {
                try await uploadVehicle(vehicle)
            } catch {
                errors.append("\(vehicle.displayName): \(error.localizedDescription)")
            }
        }
        if !errors.isEmpty {
            throw FirestoreSyncError.partialSyncFailure(details: errors.joined(separator: "; "))
        }
    }

    // MARK: - Snapshot Handling

    private func handleSnapshot(_ snapshot: QuerySnapshot, modelContext: ModelContext) {
        for change in snapshot.documentChanges {
            let data = change.document.data()
            let docId = change.document.documentID

            switch change.type {
            case .added, .modified:
                guard let vehicle = dictToVehicle(data, docId: docId) else {
                    print("[Fleet] Warning: Failed to parse vehicle from Firestore document \(docId). Skipping.")
                    continue
                }
                // Check if vehicle already exists locally
                let targetId = vehicle.id
                let descriptor = FetchDescriptor<Vehicle>(predicate: #Predicate { $0.id == targetId })
                do {
                    if let existing = try modelContext.fetch(descriptor).first {
                        existing.make = vehicle.make
                        existing.model = vehicle.model
                        existing.year = vehicle.year
                        existing.trim = vehicle.trim
                        existing.color = vehicle.color
                        existing.mileage = vehicle.mileage
                        existing.vin = vehicle.vin
                        existing.imageURL = vehicle.imageURL
                        existing.registration = vehicle.registration
                        existing.insurance = vehicle.insurance
                        existing.recalls = vehicle.recalls
                        existing.maintenanceRecords = vehicle.maintenanceRecords
                        existing.valuation = vehicle.valuation
                    } else {
                        modelContext.insert(vehicle)
                    }
                } catch {
                    print("[Fleet] Warning: SwiftData fetch failed for vehicle \(docId): \(error.localizedDescription)")
                }

            case .removed:
                guard let uuid = UUID(uuidString: docId) else {
                    print("[Fleet] Warning: Invalid UUID in Firestore document ID: \(docId)")
                    continue
                }
                let descriptor = FetchDescriptor<Vehicle>(predicate: #Predicate { $0.id == uuid })
                do {
                    if let existing = try modelContext.fetch(descriptor).first {
                        modelContext.delete(existing)
                    }
                } catch {
                    print("[Fleet] Warning: SwiftData fetch failed during delete for \(docId): \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Conversion Helpers

    func vehicleToDict(_ vehicle: Vehicle) -> [String: Any] {
        var dict: [String: Any] = [
            "make": vehicle.make,
            "model": vehicle.model,
            "year": vehicle.year,
            "trim": vehicle.trim,
            "color": vehicle.color,
            "mileage": vehicle.mileage,
            "vin": vehicle.vin,
            "imageURL": vehicle.imageURL,
            "registration": [
                "expiryDate": Timestamp(date: vehicle.registration.expiryDate),
                "state": vehicle.registration.state
            ],
            "insurance": [
                "provider": vehicle.insurance.provider,
                "coverageType": vehicle.insurance.coverageType,
                "expiryDate": Timestamp(date: vehicle.insurance.expiryDate)
            ],
            "recalls": vehicle.recalls.map { recall in
                [
                    "id": recall.id.uuidString,
                    "title": recall.title,
                    "description": recall.details,
                    "source": recall.source,
                    "dateIssued": Timestamp(date: recall.dateIssued),
                    "isResolved": recall.isResolved
                ] as [String: Any]
            },
            "maintenanceRecords": vehicle.maintenanceRecords.map { record in
                var r: [String: Any] = [
                    "id": record.id.uuidString,
                    "title": record.title,
                    "date": Timestamp(date: record.date),
                    "provider": record.provider,
                    "isCompleted": record.isCompleted
                ]
                if let mileage = record.mileage {
                    r["mileage"] = mileage
                }
                return r
            },
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        if let val = vehicle.valuation {
            dict["valuation"] = [
                "tradeIn": val.tradeIn,
                "privateSale": val.privateSale,
                "dealer": val.dealer,
                "trend": [
                    "amount": val.trend.amount,
                    "direction": val.trend.direction.rawValue,
                    "description": val.trend.summary
                ],
                "lastUpdated": Timestamp(date: val.lastUpdated)
            ] as [String: Any]
        }

        return dict
    }

    func dictToVehicle(_ data: [String: Any], docId: String) -> Vehicle? {
        guard let uuid = UUID(uuidString: docId),
              let make = data["make"] as? String,
              let model = data["model"] as? String,
              let year = data["year"] as? Int else {
            return nil
        }

        let trim = data["trim"] as? String ?? ""
        let color = data["color"] as? String ?? ""
        let mileage = data["mileage"] as? Int ?? 0
        let vin = data["vin"] as? String ?? ""
        let imageURL = data["imageURL"] as? String ?? ""

        // Registration
        let regData = data["registration"] as? [String: Any] ?? [:]
        let regExpiry = (regData["expiryDate"] as? Timestamp)?.dateValue() ?? Date()
        let regState = regData["state"] as? String ?? ""
        let registration = RegistrationInfo(expiryDate: regExpiry, state: regState)

        // Insurance
        let insData = data["insurance"] as? [String: Any] ?? [:]
        let insProvider = insData["provider"] as? String ?? ""
        let insCoverage = insData["coverageType"] as? String ?? ""
        let insExpiry = (insData["expiryDate"] as? Timestamp)?.dateValue() ?? Date()
        let insurance = InsuranceInfo(provider: insProvider, coverageType: insCoverage, expiryDate: insExpiry)

        // Recalls
        let recallsData = data["recalls"] as? [[String: Any]] ?? []
        let recalls = recallsData.compactMap { r -> Recall? in
            guard let idStr = r["id"] as? String, let id = UUID(uuidString: idStr),
                  let title = r["title"] as? String else { return nil }
            return Recall(
                id: id,
                title: title,
                details: r["description"] as? String ?? "",
                source: r["source"] as? String ?? "",
                dateIssued: (r["dateIssued"] as? Timestamp)?.dateValue() ?? Date(),
                isResolved: r["isResolved"] as? Bool ?? false
            )
        }

        // Maintenance records
        let maintData = data["maintenanceRecords"] as? [[String: Any]] ?? []
        let maintenanceRecords = maintData.compactMap { m -> MaintenanceRecord? in
            guard let idStr = m["id"] as? String, let id = UUID(uuidString: idStr),
                  let title = m["title"] as? String else { return nil }
            return MaintenanceRecord(
                id: id,
                title: title,
                date: (m["date"] as? Timestamp)?.dateValue() ?? Date(),
                provider: m["provider"] as? String ?? "",
                isCompleted: m["isCompleted"] as? Bool ?? false,
                mileage: m["mileage"] as? Int
            )
        }

        // Valuation
        var valuation: Valuation?
        if let valData = data["valuation"] as? [String: Any],
           let tradeIn = valData["tradeIn"] as? Int,
           let privateSale = valData["privateSale"] as? Int,
           let dealer = valData["dealer"] as? Int,
           let trendData = valData["trend"] as? [String: Any] {
            let trendAmount = trendData["amount"] as? Int ?? 0
            let trendDir = ValuationTrend.TrendDirection(rawValue: trendData["direction"] as? String ?? "up") ?? .up
            let trendDesc = trendData["description"] as? String ?? ""
            let lastUpdated = (valData["lastUpdated"] as? Timestamp)?.dateValue() ?? Date()
            valuation = Valuation(
                tradeIn: tradeIn,
                privateSale: privateSale,
                dealer: dealer,
                trend: ValuationTrend(amount: trendAmount, direction: trendDir, summary: trendDesc),
                lastUpdated: lastUpdated
            )
        }

        return Vehicle(
            id: uuid,
            make: make,
            model: model,
            year: year,
            trim: trim,
            color: color,
            mileage: mileage,
            vin: vin,
            imageURL: imageURL,
            registration: registration,
            insurance: insurance,
            recalls: recalls,
            maintenanceRecords: maintenanceRecords,
            valuation: valuation
        )
    }
}

// MARK: - Error Types

enum FirestoreSyncError: LocalizedError {
    case partialSyncFailure(details: String)

    var errorDescription: String? {
        switch self {
        case .partialSyncFailure(let details):
            return "Some vehicles failed to sync: \(details)"
        }
    }
}
