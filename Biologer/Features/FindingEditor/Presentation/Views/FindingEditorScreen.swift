import SwiftUI

struct FindingEditorScreen: View {
    @ObservedObject private var viewModel: FindingEditorViewModel
    private let onSaved: (UUID) -> Void
    private let onSelectLocation: (FindingEditorLocation?) -> Void
    private let onSelectTaxon: () -> Void
    private let onAddPhoto: (FindingEditorPhotoSource) -> Void
    private let onShowPhotos: ([FindingEditorPhoto], Int) -> Void

    init(
        viewModel: FindingEditorViewModel,
        onSaved: @escaping (UUID) -> Void,
        onSelectLocation: @escaping (FindingEditorLocation?) -> Void,
        onSelectTaxon: @escaping () -> Void,
        onAddPhoto: @escaping (FindingEditorPhotoSource) -> Void,
        onShowPhotos: @escaping ([FindingEditorPhoto], Int) -> Void
    ) {
        self.viewModel = viewModel
        self.onSaved = onSaved
        self.onSelectLocation = onSelectLocation
        self.onSelectTaxon = onSelectTaxon
        self.onAddPhoto = onAddPhoto
        self.onShowPhotos = onShowPhotos
    }

    var body: some View {
        content
            .biologerScreen(title: navigationTitle)
            .onAppear(perform: viewModel.load)
            .alert(item: $viewModel.alert) { alert in
                Alert(
                    title: Text(alertTitle(alert)),
                    message: Text(alertMessage(alert)),
                    dismissButton: .default(Text("Common.btn.ok".localized)) {
                        guard let findingID = viewModel.confirmAlert(alert) else { return }
                        onSaved(findingID)
                    }
                )
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadState {
        case .idle, .loading:
            BiologerLoadingStateView(
                message: "FindingEditor.loading".localized
            )
        case .content:
            editorContent
        case .failure:
            BiologerMessageStateView(
                systemImage: "exclamationmark.arrow.triangle.2.circlepath",
                title: "FindingEditor.loadError".localized,
                actionTitle: "ListOfFindings.retry".localized,
                style: .failure,
                action: viewModel.retryLoad
            )
        }
    }

    private var editorContent: some View {
        ScrollView {
            LazyVStack(spacing: BiologerSpacing.large) {
                locationSection
                photoSection
                taxonSection
                individualsSection

                if !viewModel.draft.observations.isEmpty {
                    observationsSection
                }

                fieldNotesSection
            }
            .padding(.horizontal, BiologerSpacing.regular)
            .padding(.top, BiologerSpacing.small)
            .padding(.bottom, BiologerSpacing.xxLarge)
        }
        .safeAreaInset(edge: .bottom) {
            saveAction
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var locationSection: some View {
        FindingEditorSection(
            title: "FindingDetails.section.location".localized,
            systemImage: "location"
        ) {
            if let location = viewModel.draft.location {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    alignment: .leading,
                    spacing: BiologerSpacing.small
                ) {
                    locationValue(
                        title: "Finding.field.latitude".localized,
                        value: coordinate(location.latitude),
                        systemImage: "arrow.up.and.down"
                    )
                    locationValue(
                        title: "Finding.field.longitude".localized,
                        value: coordinate(location.longitude),
                        systemImage: "arrow.left.and.right"
                    )
                    locationValue(
                        title: "Finding.field.altitude".localized,
                        value: meters(location.altitude),
                        systemImage: "mountain.2"
                    )
                    locationValue(
                        title: "Finding.field.accuracy".localized,
                        value: meters(location.accuracy),
                        systemImage: "scope"
                    )
                }
            } else {
                HStack(spacing: BiologerSpacing.small) {
                    BiologerIconBadge(systemImage: "location.slash", size: 36)
                    Text("FindingEditor.location.waiting".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Button {
                onSelectLocation(viewModel.draft.location)
            } label: {
                HStack(spacing: BiologerSpacing.xSmall) {
                    Image(systemName: "map")
                    Text("FindingEditor.location.set".localized)
                }
            }
            .buttonStyle(BiologerActionButtonStyle(isFilled: false))
        }
    }

    private var photoSection: some View {
        FindingEditorSection(
            title: "FindingDetails.section.photos".localized,
            systemImage: "photo.on.rectangle.angled"
        ) {
            FindingEditorPhotoSection(
                photos: viewModel.draft.photos,
                onCamera: { requestPhoto(from: .camera) },
                onLibrary: { requestPhoto(from: .photoLibrary) },
                onOpen: showPhoto,
                onDelete: viewModel.removePhoto
            )
        }
    }

    private var taxonSection: some View {
        FindingEditorSection(
            title: "FindingEditor.section.taxon".localized,
            systemImage: "leaf"
        ) {
            Button(action: onSelectTaxon) {
                HStack(spacing: BiologerSpacing.small) {
                    BiologerIconBadge(systemImage: "text.magnifyingglass", size: 38)

                    VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                        Text("FindingEditor.taxon.name".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(
                            viewModel.draft.taxonName.isEmpty
                                ? "FindingEditor.taxon.search".localized
                                : viewModel.draft.taxonName
                        )
                        .font(.body.weight(.medium))
                        .foregroundColor(BiologerColors.textPrimary)
                        .multilineTextAlignment(.leading)
                    }

                    Spacer(minLength: BiologerSpacing.xSmall)

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(BiologerColors.accent)
                }
                .padding(BiologerSpacing.small)
                .background(
                    BiologerColors.pageBackground,
                    in: RoundedRectangle(cornerRadius: BiologerRadius.control)
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("FindingEditor.taxon.searchHint".localized)

            if let taxon = viewModel.draft.taxon, !taxon.developmentStages.isEmpty {
                optionMenu(
                    title: "Finding.field.developmentStage".localized,
                    systemImage: "circle.hexagongrid",
                    selection: viewModel.draft.developmentStage,
                    options: taxon.developmentStages,
                    onSelect: { viewModel.draft.developmentStage = $0 }
                )
            }

            if viewModel.draft.taxon?.usesAtlasCodes == true {
                optionMenu(
                    title: "Finding.field.nestingAtlasCode".localized,
                    systemImage: "bird",
                    selection: viewModel.draft.atlasCode,
                    options: atlasOptions,
                    onSelect: { viewModel.draft.atlasCode = $0 }
                )
            }
        }
    }

    private var individualsSection: some View {
        FindingEditorSection(
            title: "FindingDetails.section.individuals".localized,
            systemImage: "number"
        ) {
            Picker(
                "FindingEditor.individuals.mode".localized,
                selection: $viewModel.draft.individualEntryMode
            ) {
                Text("FindingEditor.individuals.total".localized)
                    .tag(FindingIndividualEntryMode.total)
                Text("FindingEditor.individuals.gender".localized)
                    .tag(FindingIndividualEntryMode.gender)
            }
            .pickerStyle(.segmented)

            switch viewModel.draft.individualEntryMode {
            case .total:
                FindingEditorCounter(
                    title: "Finding.field.individuals".localized,
                    systemImage: "sum",
                    value: $viewModel.draft.totalIndividuals
                )
            case .gender:
                FindingEditorCounter(
                    title: "Finding.field.maleIndividuals".localized,
                    systemImage: "person",
                    value: $viewModel.draft.maleIndividuals
                )
                Divider()
                FindingEditorCounter(
                    title: "Finding.field.femaleIndividuals".localized,
                    systemImage: "person.fill",
                    value: $viewModel.draft.femaleIndividuals
                )
            }
        }
    }

    private var observationsSection: some View {
        FindingEditorSection(
            title: "FindingDetails.section.observations".localized,
            systemImage: "eye"
        ) {
            ForEach(viewModel.draft.observations) { observation in
                Button {
                    viewModel.toggleObservation(id: observation.id)
                } label: {
                    HStack(spacing: BiologerSpacing.small) {
                        Image(
                            systemName: observation.isSelected
                                ? "checkmark.circle.fill"
                                : "circle"
                        )
                        .font(.title3)
                        .foregroundColor(
                            observation.isSelected
                                ? BiologerColors.accent
                                : Color(uiColor: .tertiaryLabel)
                        )

                        Text(observation.name)
                            .font(.body)
                            .foregroundColor(BiologerColors.textPrimary)

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var fieldNotesSection: some View {
        FindingEditorSection(
            title: "FindingDetails.section.notes".localized,
            systemImage: "note.text"
        ) {
            FindingEditorField(
                title: "Finding.field.comment".localized,
                systemImage: "text.bubble",
                prompt: "Finding.field.comment".localized,
                text: $viewModel.draft.comment,
                axis: .vertical
            )

            FindingEditorField(
                title: "Finding.field.habitat".localized,
                systemImage: "leaf",
                prompt: "Finding.field.habitat".localized,
                text: $viewModel.draft.habitat
            )

            FindingEditorField(
                title: "Finding.field.foundOn".localized,
                systemImage: "magnifyingglass",
                prompt: "Finding.field.foundOn".localized,
                text: $viewModel.draft.foundOn
            )

            Toggle(isOn: $viewModel.draft.isFoundDead) {
                Label("Finding.field.foundDead".localized, systemImage: "cross.case")
                    .font(.body.weight(.medium))
                    .foregroundColor(BiologerColors.textPrimary)
            }
            .tint(BiologerColors.accent)

            if viewModel.draft.isFoundDead {
                FindingEditorField(
                    title: "Finding.field.causeOfDeath".localized,
                    systemImage: "text.alignleft",
                    prompt: "Finding.field.causeOfDeath".localized,
                    text: $viewModel.draft.causeOfDeath
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.draft.isFoundDead)
    }

    private var saveAction: some View {
        Button(action: viewModel.save) {
            HStack(spacing: BiologerSpacing.xSmall) {
                if viewModel.isSaving {
                    BiologerActivityIndicator(
                        size: .compact,
                        tone: .inverse
                    )
                } else {
                    Image(systemName: "checkmark.circle")
                }
                Text(
                    viewModel.isSaving
                        ? "FindingEditor.action.saving".localized
                        : "FindingEditor.action.save".localized
                )
            }
        }
        .buttonStyle(BiologerActionButtonStyle())
        .disabled(viewModel.isBusy)
        .padding(.horizontal, BiologerSpacing.regular)
        .padding(.vertical, BiologerSpacing.small)
        .background(.ultraThinMaterial)
    }

    private var navigationTitle: String {
        viewModel.isEditing
            ? "FindingEditor.nav.edit".localized
            : "FindingEditor.nav.create".localized
    }

    private var atlasOptions: [FindingEditorOption] {
        (1...17).map {
            FindingEditorOption(
                id: $0,
                name: "NestingAtlasCode.title.\($0)".localized
            )
        }
    }

    private func requestPhoto(from source: FindingEditorPhotoSource) {
        guard viewModel.canAddPhoto() else { return }
        onAddPhoto(source)
    }

    private func showPhoto(at index: Int) {
        guard let presentation = viewModel.photoPresentation(at: index) else { return }
        onShowPhotos(presentation.0, presentation.1)
    }

    private func locationValue(
        title: String,
        value: String,
        systemImage: String
    ) -> some View {
        HStack(alignment: .top, spacing: BiologerSpacing.xSmall) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundColor(BiologerColors.accent)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline.monospacedDigit().weight(.medium))
                    .foregroundColor(BiologerColors.textPrimary)
            }
        }
    }

    private func optionMenu(
        title: String,
        systemImage: String,
        selection: FindingEditorOption?,
        options: [FindingEditorOption],
        onSelect: @escaping (FindingEditorOption) -> Void
    ) -> some View {
        Menu {
            ForEach(options) { option in
                Button(option.name) { onSelect(option) }
            }
        } label: {
            HStack(spacing: BiologerSpacing.small) {
                BiologerIconBadge(systemImage: systemImage, size: 32)
                VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(selection?.name ?? "FindingEditor.option.select".localized)
                        .font(.body.weight(.medium))
                        .foregroundColor(BiologerColors.textPrimary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(BiologerColors.accent)
            }
            .padding(BiologerSpacing.small)
            .background(BiologerColors.pageBackground, in: RoundedRectangle(cornerRadius: BiologerRadius.control))
        }
    }

    private func coordinate(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(5)))
    }

    private func meters(_ value: Double) -> String {
        "\(value.formatted(.number.precision(.fractionLength(1)))) m"
    }

    private func alertTitle(_ alert: FindingEditorAlert) -> String {
        switch alert.kind {
        case .photoLimit:
            "FindingEditor.photo.limit.title".localized
        case .validation, .saveFailure:
            "API.lb.error".localized
        case .saveSuccess:
            "FindingEditor.saveSuccess.title".localized
        }
    }

    private func alertMessage(_ alert: FindingEditorAlert) -> String {
        switch alert.kind {
        case .photoLimit:
            "FindingEditor.photo.limit.message".localized
        case .saveFailure:
            "FindingEditor.saveError".localized
        case .saveSuccess(let isEditing):
            isEditing
                ? "FindingEditor.saveSuccess.updated".localized
                : "FindingEditor.saveSuccess.created".localized
        case .validation(let error):
            switch error {
            case .locationRequired:
                "FindingEditor.validation.location".localized
            case .taxonRequired:
                "FindingEditor.validation.taxonName".localized
            case .individualCountRequired:
                "FindingEditor.validation.individuals".localized
            }
        }
    }
}
