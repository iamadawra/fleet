import SwiftUI
import SwiftData

struct GarageHomeView: View {
    @Query private var vehicles: [Vehicle]
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.modelContext) private var modelContext
    @State private var selectedVehicle: Vehicle?
    @State private var showAddVehicle = false
    @State private var vehicleToDelete: Vehicle?
    @State private var showDeleteConfirmation = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FleetTheme.garageBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(greeting), \(authService.currentUser?.firstName ?? "there")")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(FleetTheme.textTertiary)

                            Text("My Garage")
                                .font(.custom("Georgia", size: 28))
                                .fontWeight(.semibold)
                                .foregroundColor(FleetTheme.textPrimary)

                            Text("\(vehicles.count) vehicles · \(GarageStatsHelper.alertCount(vehicles)) alerts pending")
                                .font(.system(size: 14))
                                .foregroundColor(FleetTheme.textSecondary)
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 12)
                        .padding(.bottom, 20)

                        // Alert chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(alertChips, id: \.text) { chip in
                                    AlertChipView(chip: chip)
                                }
                            }
                            .padding(.horizontal, 22)
                        }
                        .padding(.bottom, 20)

                        // Vehicle cards
                        ForEach(vehicles) { vehicle in
                            NavigationLink(value: vehicle) {
                                VehicleCardView(vehicle: vehicle)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    vehicleToDelete = vehicle
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete Vehicle", systemImage: "trash")
                                }
                            }
                        }

                        // Add vehicle button
                        Button(action: { showAddVehicle = true }) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(FleetTheme.accentPurple.opacity(0.12))
                                        .frame(width: 30, height: 30)
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(FleetTheme.accentPurple)
                                }
                                Text("Add a vehicle")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(FleetTheme.accentPurple)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 80)
                            .background(FleetTheme.accentPurple.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: FleetTheme.cardRadius))
                            .overlay(
                                RoundedRectangle(cornerRadius: FleetTheme.cardRadius)
                                    .strokeBorder(FleetTheme.accentPurple.opacity(0.25), style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                            )
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationDestination(for: Vehicle.self) { vehicle in
                CarDetailView(vehicle: vehicle)
            }
            .sheet(isPresented: $showAddVehicle) {
                AddVehicleView()
            }
            .alert("Delete Vehicle", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    vehicleToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let vehicle = vehicleToDelete {
                        let vehicleName = vehicle.displayName
                        Task {
                            do {
                                try await firestoreService.deleteVehicle(vehicle)
                            } catch {
                                toastManager.showError("Failed to delete \(vehicleName) from cloud: \(error.localizedDescription)")
                            }
                        }
                        modelContext.delete(vehicle)
                        toastManager.showSuccess("\(vehicleName) removed from your garage.")
                    }
                    vehicleToDelete = nil
                }
            } message: {
                if let vehicle = vehicleToDelete {
                    Text("Are you sure you want to delete \(vehicle.displayName)? This cannot be undone.")
                }
            }
        }
    }

    private var alertChips: [AlertChip] {
        var chips: [AlertChip] = []
        for vehicle in vehicles {
            let openRecalls = vehicle.recalls.filter { !$0.isResolved }
            if !openRecalls.isEmpty {
                chips.append(AlertChip(type: .urgent, text: "Recall: \(vehicle.make)"))
            }
            if vehicle.registration.isExpiringSoon {
                chips.append(AlertChip(type: .warning, text: "Reg due in \(vehicle.registration.daysUntilExpiry)d"))
            }
        }
        let allInsuranceOK = vehicles.allSatisfy { $0.insurance.isActive }
        if allInsuranceOK && !vehicles.isEmpty {
            chips.append(AlertChip(type: .ok, text: "Insurance OK"))
        }
        chips.append(AlertChip(type: .ok, text: "Oil change OK"))
        return chips
    }
}

struct AlertChip: Hashable {
    enum ChipType { case ok, warning, urgent }
    let type: ChipType
    let text: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
}

struct AlertChipView: View {
    let chip: AlertChip

    var backgroundColor: Color {
        switch chip.type {
        case .ok: return FleetTheme.pastelMint
        case .warning: return Color(hex: "FFF3D6")
        case .urgent: return Color(hex: "FFD6D6")
        }
    }

    var textColor: Color {
        switch chip.type {
        case .ok: return Color(hex: "1A7A56")
        case .warning: return Color(hex: "B86800")
        case .urgent: return Color(hex: "CC2B2B")
        }
    }

    var dotColor: Color {
        switch chip.type {
        case .ok: return FleetTheme.accentGreen
        case .warning: return Color(hex: "F0A020")
        case .urgent: return FleetTheme.accentRed
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)
            Text(chip.text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(backgroundColor)
        .clipShape(Capsule())
    }
}
