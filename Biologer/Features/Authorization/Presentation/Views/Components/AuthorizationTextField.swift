import SwiftUI
import UIKit

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
