import SwiftUI

struct FindingLocationScreen: View {
    @StateObject private var viewModel: FindingLocationViewModel
    private let onSelect: Observer<FindingEditorLocation>

    init(
        initialLocation: FindingEditorLocation?,
        useCases: FindingLocationUseCases,
        onSelect: @escaping Observer<FindingEditorLocation>
    ) {
        _viewModel = StateObject(
            wrappedValue: FindingLocationViewModel(
                initialLocation: initialLocation,
                useCases: useCases
            )
        )
        self.onSelect = onSelect
    }

    var body: some View {
        FindingLocationMapView(
            selectedLocation: viewModel.selectedLocation,
            cameraTarget: viewModel.cameraTarget,
            mapStyle: viewModel.mapStyle,
            onCoordinateSelected: viewModel.selectCoordinate
        )
        .ignoresSafeArea(edges: .bottom)
        .overlay(alignment: .top) {
            VStack(spacing: 0) {
                statusBanner
                HStack {
                    Spacer()
                    mapControls
                }
                Spacer()
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            selectionCard
        }
        .navigationTitle("FindingEditor.location.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .tint(BiologerColors.accent)
        .onAppear(perform: viewModel.start)
        .onDisappear(perform: viewModel.stop)
    }

    @ViewBuilder
    private var statusBanner: some View {
        switch viewModel.status {
        case .locating:
            banner(
                text: "FindingLocation.locating".localized,
                systemImage: "location.fill",
                showsProgress: true
            )
        case .authorizationDenied:
            banner(
                text: "FindingLocation.permissionDenied".localized,
                systemImage: "location.slash"
            )
        case .unavailable:
            banner(
                text: "FindingLocation.unavailable".localized,
                systemImage: "exclamationmark.triangle"
            )
        case .idle, .ready:
            EmptyView()
        }
    }

    private var mapControls: some View {
        VStack(spacing: BiologerSpacing.xSmall) {
            mapControlButton(
                systemImage: "location.fill",
                accessibilityLabel: "FindingLocation.current".localized,
                action: viewModel.useCurrentLocation
            )

            Menu {
                Picker(
                    "FindingLocation.mapType".localized,
                    selection: $viewModel.mapStyle
                ) {
                    ForEach(FindingLocationMapStyle.allCases) { style in
                        Text(style.localizedTitle).tag(style)
                    }
                }
            } label: {
                Image(systemName: "map.fill")
                    .font(.body.weight(.semibold))
                    .foregroundColor(BiologerColors.accent)
                    .frame(width: 44, height: 44)
                    .background(.regularMaterial, in: Circle())
                    .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
            }
            .accessibilityLabel("FindingLocation.mapType".localized)
        }
        .padding(BiologerSpacing.regular)
    }

    private var selectionCard: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.small) {
            HStack(spacing: BiologerSpacing.xSmall) {
                BiologerIconBadge(systemImage: "mappin.and.ellipse", size: 36)
                VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                    Text("FindingLocation.selected".localized)
                        .font(.headline)
                        .foregroundColor(BiologerColors.textPrimary)
                    Text("FindingLocation.tapHint".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if let location = viewModel.selectedLocation {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    alignment: .leading,
                    spacing: BiologerSpacing.xSmall
                ) {
                    value(
                        title: "Finding.field.latitude".localized,
                        text: coordinate(location.latitude)
                    )
                    value(
                        title: "Finding.field.longitude".localized,
                        text: coordinate(location.longitude)
                    )
                    value(
                        title: "Finding.field.altitude".localized,
                        text: meters(location.altitude)
                    )
                    value(
                        title: "Finding.field.accuracy".localized,
                        text: meters(location.accuracy)
                    )
                }
            }

            Button {
                Task {
                    guard let location = await viewModel.confirmSelection() else { return }
                    onSelect(location)
                }
            } label: {
                HStack(spacing: BiologerSpacing.xSmall) {
                    if viewModel.isResolvingAltitude {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "checkmark.circle")
                    }
                    Text(
                        viewModel.isResolvingAltitude
                            ? "FindingLocation.resolvingAltitude".localized
                            : "FindingLocation.confirm".localized
                    )
                }
            }
            .buttonStyle(BiologerActionButtonStyle())
            .disabled(!viewModel.canConfirm)
            .opacity(viewModel.canConfirm ? 1 : 0.55)
        }
        .padding(BiologerSpacing.regular)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) { Divider() }
    }

    private func banner(
        text: String,
        systemImage: String,
        showsProgress: Bool = false
    ) -> some View {
        HStack(spacing: BiologerSpacing.xSmall) {
            if showsProgress {
                ProgressView().tint(BiologerColors.accent)
            } else {
                Image(systemName: systemImage)
                    .foregroundColor(BiologerColors.accent)
            }
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundColor(BiologerColors.textPrimary)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, BiologerSpacing.regular)
        .padding(.vertical, BiologerSpacing.small)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.1), radius: 8, y: 3)
        .padding(.horizontal, BiologerSpacing.regular)
        .padding(.top, BiologerSpacing.small)
    }

    private func mapControlButton(
        systemImage: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .foregroundColor(BiologerColors.accent)
                .frame(width: 44, height: 44)
                .background(.regularMaterial, in: Circle())
                .shadow(color: .black.opacity(0.12), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private func value(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(text)
                .font(.subheadline.monospacedDigit().weight(.medium))
                .foregroundColor(BiologerColors.textPrimary)
        }
    }

    private func coordinate(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(5)))
    }

    private func meters(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(1)))) m"
    }
}
