import Foundation
import FirebaseFirestore
import SwiftData

@MainActor
class FirestoreService: ObservableObject {
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private var userId: String?

    // MARK: - Listener Management

    func startListening(userId: String, modelContext: ModelContext) {
        stopListening()
        self.userId = userId

        listener = db.collection("users").document(userId).collection("vehicles")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self, let snapshot else { return }
                Task { @MainActor in
                    self.handleSnapshot(snapshot, modelContext: modelContext)
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        userId = nil
    }

    // MARK: - CRUD Operations

    func uploadVehicle(_ vehicle: Vehicle) {
        guard let userId else { return }
        let data = vehicleToDict(vehicle)
        db.collection("users").document(userId).collection("vehicles")
            .document(vehicle.id.uuidString)
            .setData(data) { error in
                if let error {
                    print("Firestore upload error: \(error.localizedDescription)")
                }
            }
    }

    func deleteVehicle(_ vehicle: Vehicle) {
        guard let userId else { return }
        db.collection("users").document(userId).collection("vehicles")
            .document(vehicle.id.uuidString)
            .delete { error in
                if let error {
                    print("Firestore delete error: \(error.localizedDescription)")
                }
            }
    }

    func syncAllLocalVehicles(modelContext: ModelContext) {
        guard userId != nil else { return }
        let descriptor = FetchDescriptor<Vehicle>()
        guard let vehicles = try? modelContext.fetch(descriptor) else { return }
        for vehicle in vehicles {
            uploadVehicle(vehicle)
        }
    }

    // MARK: - Snapshot Handling

    private func handleSnapshot(_ snapshot: QuerySnapshot, modelContext: ModelContext) {
        for change in snapshot.documentChanges {
            let data = change.document.data()
            let docId = change.document.documentID

            switch change.type {
            case .added, .modified:
                guard let vehicle = dictToVehicle(data, docId: docId) else { continue }
                // Check if vehicle already exists locally
                let targetId = vehicle.id
                let descriptor = FetchDescriptor<Vehicle>(predicate: #Predicate { $0.id == targetId })
                if let existing = try? modelContext.fetch(descriptor).first {
                    // Update existing
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

            case .removed:
                guard let uuid = UUID(uuidString: docId) else { continue }
                let descriptor = FetchDescriptor<Vehicle>(predicate: #Predicate { $0.id == uuid })
                if let existing = try? modelContext.fetch(descriptor).first {
                    modelContext.delete(existing)
                }
            }
        }
    }

    // MARK: - Conversion Helpers

    private func vehicleToDict(_ vehicle: Vehicle) -> [String: Any] {
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
                    "description": recall.description,
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
                    "description": val.trend.description
                ],
                "lastUpdated": Timestamp(date: val.lastUpdated)
            ] as [String: Any]
        }

        return dict
    }

    private func dictToVehicle(_ data: [String: Any], docId: String) -> Vehicle? {
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
                description: r["description"] as? String ?? "",
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
                trend: ValuationTrend(amount: trendAmount, direction: trendDir, description: trendDesc),
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
