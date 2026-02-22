import SwiftUI

struct AddVehicleView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var trim = ""
    @State private var color = ""
    @State private var vin = ""
    @State private var mileage = ""

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

                        // Form fields
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

                        // Add button
                        Button(action: { dismiss() }) {
                            Text("Add Vehicle")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [FleetTheme.accentPurple, FleetTheme.accentBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: FleetTheme.accentPurple.opacity(0.35), radius: 12, y: 6)
                        }
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
