import SwiftUI

// MARK: - Toast Model

struct Toast: Equatable, Identifiable {
    let id = UUID()
    let type: ToastType
    let message: String

    enum ToastType {
        case success, error, warning

        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }

        var backgroundColor: Color {
            switch self {
            case .success: return Color(hex: "D4F5E9")
            case .error: return Color(hex: "FFD6D6")
            case .warning: return Color(hex: "FFF3D6")
            }
        }

        var foregroundColor: Color {
            switch self {
            case .success: return Color(hex: "1A7A56")
            case .error: return Color(hex: "CC2B2B")
            case .warning: return Color(hex: "B86800")
            }
        }

        var iconColor: Color {
            switch self {
            case .success: return FleetTheme.accentGreen
            case .error: return FleetTheme.accentRed
            case .warning: return Color(hex: "F0A020")
            }
        }
    }

    static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Toast Manager

@MainActor
class ToastManager: ObservableObject {
    @Published var currentToast: Toast?
    private var dismissTask: Task<Void, Never>?

    func show(_ message: String, type: Toast.ToastType, duration: TimeInterval = 3.0) {
        dismissTask?.cancel()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentToast = Toast(type: type, message: message)
        }
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                currentToast = nil
            }
        }
    }

    func showSuccess(_ message: String) {
        show(message, type: .success)
    }

    func showError(_ message: String) {
        show(message, type: .error)
    }

    func showWarning(_ message: String) {
        show(message, type: .warning)
    }
}

// MARK: - Toast View

struct ToastView: View {
    let toast: Toast
    var onDismiss: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(toast.type.iconColor)

            Text(toast.message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(toast.type.foregroundColor)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button {
                onDismiss?()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(toast.type.foregroundColor.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(toast.type.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .padding(.horizontal, 16)
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if let toast = toastManager.currentToast {
                    ToastView(toast: toast) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            toastManager.currentToast = nil
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
                    .zIndex(1)
                }
            }
    }
}

extension View {
    func toast(_ toastManager: ToastManager) -> some View {
        modifier(ToastModifier(toastManager: toastManager))
    }
}
