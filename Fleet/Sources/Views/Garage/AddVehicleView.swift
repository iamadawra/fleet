import SwiftUI
import SwiftData

struct AddVehicleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var trim = ""
    @State private var color = ""
    @State private var vin = ""
    @State private var mileage = ""
    @State private var registrationExpiry = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    @State private var registrationState = ""
    @State private var insuranceProvider = ""
    @State private var insuranceCoverage = "Full"
    @State private var insuranceExpiry = Calendar.current.date(byAdding: .year, value: 1, to: Date())!

    private var isFormValid: Bool {
        !make.trimmingCharacters(in: .whitespaces).isEmpty &&
        !model.trimmingCharacters(in: .whitespaces).isEmpty &&
        !year.trimmingCharacters(in: .whitespaces).isEmpty &&
        Int(year) != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FleetTheme.garageBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
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
                            HStack(spacing: 14) {
                                FleetTextField(title: "Make", text: $make, placeholder: "e.g. Tesla")
                                FleetTextField(title: "Model", text: $model, placeholder: "e.g. Model 3")
                            }
                            HStack(spacing: 14) {
                                FleetTextField(title: "Year", text: $year, placeholder: "2024")
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

                        // Add button
                        Button(action: saveVehicle) {
                            Text("Add Vehicle")
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
        }
    }

    private func saveVehicle() {
        let vehicle = Vehicle(
            make: make.trimmingCharacters(in: .whitespaces),
            model: model.trimmingCharacters(in: .whitespaces),
            year: Int(year) ?? 2024,
            trim: trim.trimmingCharacters(in: .whitespaces),
            color: color.trimmingCharacters(in: .whitespaces),
            mileage: Int(mileage.replacingOccurrences(of: ",", with: "")) ?? 0,
            vin: vin.trimmingCharacters(in: .whitespaces),
            imageURL: "",
            registration: RegistrationInfo(
                expiryDate: registrationExpiry,
                state: registrationState.trimmingCharacters(in: .whitespaces)
            ),
            insurance: InsuranceInfo(
                provider: insuranceProvider.trimmingCharacters(in: .whitespaces),
                coverageType: insuranceCoverage.trimmingCharacters(in: .whitespaces),
                expiryDate: insuranceExpiry
            )
        )
        modelContext.insert(vehicle)
        dismiss()
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
