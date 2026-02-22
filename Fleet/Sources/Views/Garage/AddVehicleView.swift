import SwiftUI
import SwiftData

struct AddVehicleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var toastManager: ToastManager
    @State private var make = ""
    @State private var model = ""
    @State private var year: Int = VehicleCatalog.years.first ?? 2025
    @State private var trim = ""
    @State private var color = ""
    @State private var vin = ""
    @State private var mileage = ""
    @State private var registrationExpiry = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    @State private var registrationState = ""
    @State private var insuranceProvider = ""
    @State private var insuranceCoverage = "Full"
    @State private var insuranceExpiry = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    @State private var validationErrors: [String] = []
    @State private var showPhotoPicker = false

    /// Models available for the currently-selected make.
    private var availableModels: [String] {
        VehicleCatalog.models(for: make)
    }

    private var isFormValid: Bool {
        !make.isEmpty && !model.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FleetTheme.garageBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Validation errors banner
                        if !validationErrors.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(validationErrors, id: \.self) { error in
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .font(.system(size: 13))
                                            .foregroundColor(FleetTheme.accentRed)
                                        Text(error)
                                            .font(.system(size: 13))
                                            .foregroundColor(Color(hex: "CC2B2B"))
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color(hex: "FFD6D6").opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        // VIN Scan card
                        VStack(spacing: 12) {
                            Image(systemName: "barcode.viewfinder")
                                .font(.system(size: 40))
                                .foregroundColor(FleetTheme.accentPurple)
                            Text("Scan VIN")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(FleetTheme.textPrimary)
                            Text("Use your camera to scan the VIN barcode")
                                .font(.system(size: 13))
                                .foregroundColor(FleetTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: FleetTheme.cardRadius))
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)

                        // Or divider
                        HStack {
                            Rectangle().fill(FleetTheme.textTertiary.opacity(0.3)).frame(height: 1)
                            Text("OR ENTER MANUALLY")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(FleetTheme.textTertiary)
                                .kerning(1)
                            Rectangle().fill(FleetTheme.textTertiary.opacity(0.3)).frame(height: 1)
                        }

                        // Vehicle info fields
                        VStack(spacing: 14) {
                            FleetTextField(title: "VIN", text: $vin, placeholder: "17-character VIN")

                            // Make picker
                            FleetPickerField(title: "Make", selection: $make, prompt: "Select Make") {
                                ForEach(VehicleCatalog.makes, id: \.self) { makeName in
                                    Text(makeName).tag(makeName)
                                }
                            }
                            .onChange(of: make) { _, _ in
                                // Reset model when make changes so the user
                                // doesn't keep a model from a different make.
                                model = ""
                            }

                            // Model picker (filtered by selected make)
                            FleetPickerField(title: "Model", selection: $model, prompt: "Select Model") {
                                ForEach(availableModels, id: \.self) { modelName in
                                    Text(modelName).tag(modelName)
                                }
                            }
                            .disabled(make.isEmpty)
                            .opacity(make.isEmpty ? 0.5 : 1)

                            HStack(spacing: 14) {
                                // Year picker
                                FleetPickerField(title: "Year", selection: $year, prompt: "Year") {
                                    ForEach(VehicleCatalog.years, id: \.self) { yr in
                                        Text(String(yr)).tag(yr)
                                    }
                                }

                                FleetTextField(title: "Trim", text: $trim, placeholder: "Long Range")
                            }
                            HStack(spacing: 14) {
                                FleetTextField(title: "Color", text: $color, placeholder: "Pearl White")
                                FleetTextField(title: "Mileage", text: $mileage, placeholder: "28,400")
                            }
                        }
                        .padding(20)
                        .background(.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: FleetTheme.cardRadius))
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)

                        // Registration & Insurance fields
                        VStack(spacing: 14) {
                            FleetTextField(title: "Registration State", text: $registrationState, placeholder: "e.g. CA")
                            FleetDateField(title: "Registration Expiry", date: $registrationExpiry)
                            FleetTextField(title: "Insurance Provider", text: $insuranceProvider, placeholder: "e.g. State Farm")
                            FleetTextField(title: "Insurance Coverage", text: $insuranceCoverage, placeholder: "Full")
                            FleetDateField(title: "Insurance Expiry", date: $insuranceExpiry)
                        }
                        .padding(20)
                        .background(.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: FleetTheme.cardRadius))
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)

                        // Next step button
                        Button(action: proceedToPhotoPicker) {
                            Text("Next: Choose Photo")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: isFormValid
                                            ? [FleetTheme.accentPurple, FleetTheme.accentBlue]
                                            : [Color.gray.opacity(0.4), Color.gray.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: isFormValid ? FleetTheme.accentPurple.opacity(0.35) : .clear, radius: 12, y: 6)
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 8)
                    }
                    .padding(18)
                }
            }
            .navigationTitle("Add Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(FleetTheme.accentPurple)
                }
            }
            .navigationDestination(isPresented: $showPhotoPicker) {
                VehiclePhotoPickerView(
                    make: make,
                    model: model,
                    year: year,
                    trim: trim.trimmingCharacters(in: .whitespaces),
                    color: color.trimmingCharacters(in: .whitespaces),
                    mileage: Int(mileage.replacingOccurrences(of: ",", with: "")) ?? 0,
                    vin: vin.trimmingCharacters(in: .whitespaces),
                    registrationExpiry: registrationExpiry,
                    registrationState: registrationState.trimmingCharacters(in: .whitespaces),
                    insuranceProvider: insuranceProvider.trimmingCharacters(in: .whitespaces),
                    insuranceCoverage: insuranceCoverage.trimmingCharacters(in: .whitespaces),
                    insuranceExpiry: insuranceExpiry,
                    dismissFlow: { dismiss() }
                )
            }
        }
    }

    private func validateForm() -> [String] {
        var errors: [String] = []

        if make.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Make is required.")
        }
        if model.trimmingCharacters(in: .whitespaces).isEmpty {
            errors.append("Model is required.")
        }

        let currentYear = Calendar.current.component(.year, from: Date())
        if year < 1886 || year > currentYear + 2 {
            errors.append("Year must be between 1886 and \(currentYear + 2).")
        }

        let cleanedMileage = mileage.replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespaces)
        if !cleanedMileage.isEmpty {
            if let mileageInt = Int(cleanedMileage) {
                if mileageInt < 0 {
                    errors.append("Mileage cannot be negative.")
                }
            } else {
                errors.append("Mileage must be a valid number.")
            }
        }

        let trimmedVin = vin.trimmingCharacters(in: .whitespaces)
        if !trimmedVin.isEmpty && trimmedVin.count != 17 {
            errors.append("VIN must be exactly 17 characters.")
        }

        return errors
    }

    private func proceedToPhotoPicker() {
        let errors = validateForm()
        withAnimation(.easeInOut(duration: 0.2)) {
            validationErrors = errors
        }
        guard errors.isEmpty else {
            toastManager.showWarning("Please fix the validation errors above.")
            return
        }
        showPhotoPicker = true
    }
}

// MARK: - Reusable Form Components

struct FleetPickerField<SelectionValue: Hashable, Content: View>: View {
    let title: String
    @Binding var selection: SelectionValue
    let prompt: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(FleetTheme.textTertiary)
                .kerning(1)
            Picker(title, selection: $selection) {
                content()
            }
            .pickerStyle(.menu)
            .font(.system(size: 15))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
            )
            .tint(FleetTheme.textPrimary)
        }
    }
}

struct FleetTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(FleetTheme.textTertiary)
                .kerning(1)
            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                )
        }
    }
}

struct FleetDateField: View {
    let title: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(FleetTheme.textTertiary)
                .kerning(1)
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                )
        }
    }
}
