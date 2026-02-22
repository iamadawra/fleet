import SwiftUI
import SwiftData

/// Step 2 of the Add Vehicle flow — lets the user choose an exterior photo
/// fetched from caranddriver.com, or fall back to a generic placeholder.
struct VehiclePhotoPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var toastManager: ToastManager

    // Vehicle data from step 1
    let make: String
    let model: String
    let year: Int
    let trim: String
    let color: String
    let mileage: Int
    let vin: String
    let registrationExpiry: Date
    let registrationState: String
    let insuranceProvider: String
    let insuranceCoverage: String
    let insuranceExpiry: Date

    /// Callback to dismiss the entire Add Vehicle sheet.
    let dismissFlow: () -> Void

    @State private var photoURLs: [URL] = []
    @State private var selectedPhotoIndex = 0
    @State private var isLoading = true
    @State private var isSaving = false

    private let imageService = CarAndDriverImageService()

    var body: some View {
        ZStack {
            FleetTheme.garageBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerView

                    if isLoading {
                        loadingView
                    } else if photoURLs.isEmpty {
                        placeholderView
                    } else {
                        photoSelectionView
                    }

                    addButton
                }
                .padding(18)
            }
        }
        .navigationTitle("Step 2 of 2")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            let photos = await imageService.fetchExteriorPhotos(make: make, model: model)
            isLoading = false
            photoURLs = photos
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 6) {
            Text("Choose a Photo")
                .font(.custom("Georgia", size: 22))
                .fontWeight(.medium)
                .foregroundColor(FleetTheme.textPrimary)
            Text("\(make) \(model)")
                .font(.system(size: 15))
                .foregroundColor(FleetTheme.textSecondary)
        }
        .padding(.top, 8)
    }

    // MARK: - Loading

    private var loadingView: some View {
        RoundedRectangle(cornerRadius: FleetTheme.cardRadius)
            .fill(.white.opacity(0.7))
            .frame(height: FleetLayout.photoPickerHeight)
            .overlay {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Finding photos on Car and Driver...")
                        .font(.system(size: 14))
                        .foregroundColor(FleetTheme.textSecondary)
                }
            }
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    // MARK: - Placeholder (no photos found)

    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: FleetTheme.cardRadius)
            .fill(.white.opacity(0.7))
            .frame(height: FleetLayout.photoPickerHeight)
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 56))
                        .foregroundColor(FleetTheme.accentPurple.opacity(0.4))
                    Text("No photos found")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(FleetTheme.textSecondary)
                    Text("A placeholder will be used for this vehicle.")
                        .font(.system(size: 13))
                        .foregroundColor(FleetTheme.textTertiary)
                }
            }
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    // MARK: - Photo Selection

    private var photoSelectionView: some View {
        VStack(spacing: 16) {
            // Main photo
            AsyncImage(url: photoURLs[selectedPhotoIndex]) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: FleetLayout.photoPickerHeight)
                        .clipped()
                case .failure:
                    fallbackImageView
                default:
                    RoundedRectangle(cornerRadius: FleetTheme.cardRadius)
                        .fill(FleetTheme.pastelBlue)
                        .frame(height: FleetLayout.photoPickerHeight)
                        .overlay { ProgressView() }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: FleetTheme.cardRadius))
            .shadow(color: .black.opacity(0.1), radius: 12, y: 4)

            // Toggle thumbnails (only when 2 photos are available)
            if photoURLs.count > 1 {
                thumbnailToggle
            }
        }
    }

    private var thumbnailToggle: some View {
        VStack(spacing: 8) {
            Text("TAP TO SWITCH PHOTO")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(FleetTheme.textTertiary)
                .kerning(1)

            HStack(spacing: 12) {
                ForEach(0..<photoURLs.count, id: \.self) { index in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPhotoIndex = index
                        }
                    } label: {
                        AsyncImage(url: photoURLs[index]) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            default:
                                Rectangle()
                                    .fill(FleetTheme.pastelBlue)
                            }
                        }
                        .frame(width: FleetLayout.thumbnailWidth, height: FleetLayout.thumbnailHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    selectedPhotoIndex == index
                                        ? FleetTheme.accentPurple
                                        : Color.clear,
                                    lineWidth: 3
                                )
                        )
                        .shadow(
                            color: selectedPhotoIndex == index
                                ? FleetTheme.accentPurple.opacity(0.3) : .clear,
                            radius: 6, y: 2
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: FleetTheme.cardRadius))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    private var fallbackImageView: some View {
        RoundedRectangle(cornerRadius: FleetTheme.cardRadius)
            .fill(FleetTheme.pastelLavender)
            .frame(height: FleetLayout.photoPickerHeight)
            .overlay {
                Image(systemName: "car.fill")
                    .font(.system(size: 48))
                    .foregroundColor(FleetTheme.accentPurple.opacity(0.4))
            }
    }

    // MARK: - Add Button

    private var addButton: some View {
        Button(action: saveVehicle) {
            HStack(spacing: 8) {
                if isSaving {
                    ProgressView()
                        .tint(.white)
                }
                Text(isSaving ? "Adding..." : "Add Vehicle")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: FleetLayout.buttonHeight)
            .background(
                LinearGradient(
                    colors: isSaving
                        ? [Color.gray.opacity(0.4), Color.gray.opacity(0.3)]
                        : [FleetTheme.accentPurple, FleetTheme.accentBlue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(
                color: isSaving ? .clear : FleetTheme.accentPurple.opacity(0.35),
                radius: 12, y: 6
            )
        }
        .disabled(isSaving || isLoading)
        .padding(.top, 8)
    }

    // MARK: - Save

    private func saveVehicle() {
        isSaving = true

        let selectedImageURL: String
        if photoURLs.isEmpty {
            selectedImageURL = ""
        } else {
            selectedImageURL = photoURLs[selectedPhotoIndex].absoluteString
        }

        let vehicle = Vehicle(
            make: make,
            model: model,
            year: year,
            trim: trim,
            color: color,
            mileage: mileage,
            vin: vin,
            imageURL: selectedImageURL,
            registration: RegistrationInfo(
                expiryDate: registrationExpiry,
                state: registrationState
            ),
            insurance: InsuranceInfo(
                provider: insuranceProvider,
                coverageType: insuranceCoverage,
                expiryDate: insuranceExpiry
            )
        )
        modelContext.insert(vehicle)

        Task {
            do {
                try await firestoreService.uploadVehicle(vehicle)
                toastManager.showSuccess("\(vehicle.displayName) added to your garage.")
            } catch {
                toastManager.showWarning("Vehicle saved locally but cloud sync failed: \(error.localizedDescription)")
            }
            isSaving = false
            dismissFlow()
        }
    }
}
