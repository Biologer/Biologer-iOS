import SwiftUI

struct FindingLocationDetailsScreen: View {
    @StateObject private var viewModel: FindingLocationDetailsViewModel

    init(location: FindingDetailsLocation) {
        _viewModel = StateObject(
            wrappedValue: FindingLocationDetailsViewModel(location: location)
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            FindingLocationDetailsMapView(
                location: viewModel.location,
                mapStyle: viewModel.mapStyle
            )
            .ignoresSafeArea(edges: .bottom)

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.16)],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            locationCard
        }
        .biologerScreen(title: "FindingLocationDetails.nav.title".localized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                mapStyleMenu
            }
        }
    }

    private var locationCard: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.regular) {
            HStack(spacing: BiologerSpacing.small) {
                BiologerIconBadge(
                    systemImage: "mappin.and.ellipse",
                    tint: BiologerColors.accent,
                    backgroundColor: BiologerColors.brandSoft,
                    size: 42
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text("FindingLocationDetails.card.title".localized)
                        .font(.headline)
                        .foregroundColor(BiologerColors.textPrimary)

                    Text(coordinateSummary)
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 0)
            }

            HStack(spacing: BiologerSpacing.small) {
                metric(
                    title: "Finding.field.altitude".localized,
                    value: meters(viewModel.location.altitude),
                    systemImage: "mountain.2"
                )
                metric(
                    title: "Finding.field.accuracy".localized,
                    value: meters(viewModel.location.accuracy),
                    systemImage: "scope"
                )
            }
        }
        .padding(BiologerSpacing.regular)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(BiologerColors.accent.opacity(0.16), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.16), radius: 18, y: 8)
        .padding(BiologerSpacing.regular)
    }

    private func metric(
        title: String,
        value: String,
        systemImage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.xSmall) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .foregroundColor(BiologerColors.accent)
                Text(title)
                    .foregroundColor(.secondary)
            }
            .font(.caption)

            Text(value)
                .font(.subheadline.monospacedDigit().weight(.semibold))
                .foregroundColor(BiologerColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(BiologerSpacing.small)
        .background(
            BiologerColors.selectedSurface,
            in: RoundedRectangle(cornerRadius: 14)
        )
    }

    private var mapStyleMenu: some View {
        Menu {
            ForEach(FindingLocationDetailsMapStyle.allCases) { style in
                Button {
                    viewModel.mapStyle = style
                } label: {
                    if viewModel.mapStyle == style {
                        Label(style.localizedTitle, systemImage: "checkmark")
                    } else {
                        Text(style.localizedTitle)
                    }
                }
            }
        } label: {
            Image(systemName: "map")
        }
        .accessibilityLabel("FindingLocationDetails.mapStyle".localized)
    }

    private var coordinateSummary: String {
        String(
            format: "%.5f, %.5f",
            viewModel.location.latitude,
            viewModel.location.longitude
        )
    }

    private func meters(_ value: Double) -> String {
        String(format: "%.0f m", value)
    }
}
