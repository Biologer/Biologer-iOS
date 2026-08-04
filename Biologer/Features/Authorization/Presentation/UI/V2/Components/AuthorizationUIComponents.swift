import SwiftUI
import UIKit

struct AuthorizationBrandHeader: View {
    var environmentImage: String?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image("biologer_logo_icon")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 300, maxHeight: 100)
                .padding(.horizontal, BiologerSpacing.regular)
                .padding(.vertical, BiologerSpacing.small)
        }
    }
}

struct AuthorizationStepHeader: View {
    let step: Int
    let totalSteps: Int
    let systemImage: String

    var body: some View {
        VStack(spacing: BiologerSpacing.regular) {
            BiologerIconBadge(
                systemImage: systemImage,
                size: 62
            )

            HStack(spacing: BiologerSpacing.xSmall) {
                ForEach(Array(1...totalSteps), id: \.self) { index in
                    Capsule()
                        .fill(
                            index <= step
                                ? BiologerColors.brandStrong
                                : BiologerColors.iconBackground
                        )
                        .frame(height: 5)
                }
            }

            Text("\(step) / \(totalSteps)")
                .font(.caption.weight(.semibold))
                .foregroundColor(BiologerColors.sectionTitle)
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}

struct AuthorizationTextField: View {
    @Binding private var text: String

    private let placeholder: String
    private let errorText: String?
    private let systemImage: String
    private let keyboardType: UIKeyboardType
    private let textContentType: UITextContentType?
    private let isPasswordField: Bool

    @State private var isSecure: Bool
    @FocusState private var isFocused: Bool

    init(
        text: Binding<String>,
        placeholder: String,
        errorText: String? = nil,
        systemImage: String,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        isSecure: Bool = false
    ) {
        _text = text
        self.placeholder = placeholder
        self.errorText = errorText
        self.systemImage = systemImage
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        isPasswordField = isSecure
        _isSecure = State(initialValue: isSecure)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: BiologerSpacing.small) {
                Image(systemName: systemImage)
                    .font(.body.weight(.semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 22)

                field
                    .focused($isFocused)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .textInputAutocapitalization(
                        isPasswordField || keyboardType == .emailAddress
                            ? .never
                            : .sentences
                    )
                    .autocorrectionDisabled(
                        isPasswordField || keyboardType == .emailAddress
                    )

                if isPasswordField {
                    Button(action: toggleSecureEntry) {
                        Image(
                            systemName: isSecure
                                ? "eye"
                                : "eye.slash"
                        )
                        .font(.body.weight(.medium))
                        .foregroundColor(BiologerColors.sectionTitle)
                        .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(placeholder)
                }
            }
            .padding(.horizontal, BiologerSpacing.regular)
            .frame(minHeight: 56)
            .background(
                BiologerColors.surface,
                in: RoundedRectangle(
                    cornerRadius: BiologerRadius.control,
                    style: .continuous
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: BiologerRadius.control,
                    style: .continuous
                )
                .stroke(borderColor, lineWidth: isFocused || hasFailure ? 1.5 : 1)
            }

            if hasFailure {
                Text(errorText ?? "")
                    .font(.caption)
                    .foregroundColor(BiologerColors.destructive)
                    .padding(.horizontal, BiologerSpacing.small)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private var field: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
        } else {
            TextField(placeholder, text: $text)
        }
    }

    private func toggleSecureEntry() {
        isSecure.toggle()

        DispatchQueue.main.async {
            isFocused = true
        }
    }

    private var hasFailure: Bool {
        !(errorText ?? "").isEmpty
    }

    private var borderColor: Color {
        if hasFailure {
            return BiologerColors.destructive
        }
        return isFocused
            ? BiologerColors.accent
            : BiologerColors.brandStrong.opacity(0.14)
    }

    private var iconColor: Color {
        hasFailure ? BiologerColors.destructive : BiologerColors.brandStrong
    }
}

struct AuthorizationNavigationCard: View {
    let title: String
    let subtitle: String?
    let systemImage: String
    let action: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: BiologerSpacing.small) {
                BiologerIconBadge(systemImage: systemImage)

                VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                    if let subtitle {
                        Text(subtitle.uppercased())
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(BiologerColors.sectionTitle)
                            .tracking(0.4)
                    }

                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundColor(BiologerColors.textPrimary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: BiologerSpacing.xSmall)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundColor(Color(uiColor: .tertiaryLabel))
            }
            .padding(BiologerSpacing.regular)
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
            .biologerCard()
        }
        .buttonStyle(.plain)
    }
}

struct AuthorizationLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()

            ProgressView()
                .controlSize(.large)
                .tint(BiologerColors.primaryActionBackground)
                .padding(BiologerSpacing.xLarge)
                .background(BiologerColors.surface, in: Circle())
                .shadow(color: .black.opacity(0.12), radius: 12, y: 5)
        }
    }
}

struct AuthorizationResultSheet: View {
    let isSuccess: Bool
    let title: String
    let message: String
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: BiologerSpacing.large) {
            BiologerIconBadge(
                systemImage: isSuccess
                    ? "checkmark.circle.fill"
                    : "exclamationmark.triangle.fill",
                tint: isSuccess
                    ? BiologerColors.primaryActionBackground
                    : BiologerColors.destructive,
                backgroundColor: isSuccess
                    ? BiologerColors.iconBackground
                    : BiologerColors.destructive.opacity(0.1),
                size: 68
            )

            VStack(spacing: BiologerSpacing.xSmall) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundColor(BiologerColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button("Common.btn.ok".localized, action: onConfirm)
                .buttonStyle(
                    BiologerActionButtonStyle(
                        role: isSuccess ? .primary : .destructive
                    )
                )
        }
        .padding(BiologerSpacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BiologerColors.pageBackground.ignoresSafeArea())
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(BiologerColors.pageBackground)
    }
}
