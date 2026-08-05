import SwiftUI

struct FindingEditorScreen: View {
    @ObservedObject private var viewModel: FindingEditorViewModel

    init(viewModel: FindingEditorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        content
            .biologerPageBackground()
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .tint(BiologerColors.accent)
            .onAppear(perform: viewModel.load)
            .alert(item: $viewModel.alert) { alert in
                Alert(
                    title: Text(alertTitle(alert)),
                    message: Text(alertMessage(alert)),
                    dismissButton: .default(Text("Common.btn.ok".localized)) {
                        viewModel.confirmAlert(alert)
                    }
                )
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadState {
        case .idle, .loading:
            loadingView
        case .content:
            editorContent
        case .failure:
            failureView
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
                        title: "NewTaxon.lb.latitude".localized,
                        value: coordinate(location.latitude),
                        systemImage: "arrow.up.and.down"
                    )
                    locationValue(
                        title: "NewTaxon.lb.longitued".localized,
                        value: coordinate(location.longitude),
                        systemImage: "arrow.left.and.right"
                    )
                    locationValue(
                        title: "NewTaxon.lb.altitude".localized,
                        value: meters(location.altitude),
                        systemImage: "mountain.2"
                    )
                    locationValue(
                        title: "NewTaxon.lb.accuracyTitle".localized,
                        value: meters(location.accuracy),
                        systemImage: "scope"
                    )
                }
            } else {
                HStack(spacing: BiologerSpacing.small) {
                    BiologerIconBadge(systemImage: "location.slash", size: 36)
                    Text("NewTaxon.lb.waitingForCordinate".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Button(action: viewModel.requestLocationSelection) {
                HStack(spacing: BiologerSpacing.xSmall) {
                    Image(systemName: "map")
                    Text("NewTaxon.btn.setLocation.title".localized)
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
                onCamera: { viewModel.requestPhoto(from: .camera) },
                onLibrary: { viewModel.requestPhoto(from: .photoLibrary) },
                onOpen: viewModel.showPhoto,
                onDelete: viewModel.removePhoto
            )
        }
    }

    private var taxonSection: some View {
        FindingEditorSection(
            title: "FindingEditor.section.taxon".localized,
            systemImage: "leaf"
        ) {
            Button(action: viewModel.requestTaxonSelection) {
                HStack(spacing: BiologerSpacing.small) {
                    BiologerIconBadge(systemImage: "text.magnifyingglass", size: 38)

                    VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                        Text("NewTaxon.tf.taxonName.placeholder".localized)
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
                    title: "NewTaxon.tf.developmentStage.placeholder".localized,
                    systemImage: "circle.hexagongrid",
                    selection: viewModel.draft.developmentStage,
                    options: taxon.developmentStages,
                    onSelect: { viewModel.draft.developmentStage = $0 }
                )
            }

            if viewModel.draft.taxon?.usesAtlasCodes == true {
                optionMenu(
                    title: "NewTaxon.tf.nesting.placeholder".localized,
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
                    title: "NewTaxon.tf.individual.placeholder".localized,
                    systemImage: "sum",
                    value: $viewModel.draft.totalIndividuals
                )
            case .gender:
                FindingEditorCounter(
                    title: "NewTaxon.tf.maleIndividual.placeholder".localized,
                    systemImage: "person",
                    value: $viewModel.draft.maleIndividuals
                )
                Divider()
                FindingEditorCounter(
                    title: "NewTaxon.tf.femaleIndividual.placeholder".localized,
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
                title: "NewTaxon.tf.comment.placeholder".localized,
                systemImage: "text.bubble",
                prompt: "NewTaxon.tf.comment.placeholder".localized,
                text: $viewModel.draft.comment,
                axis: .vertical
            )

            FindingEditorField(
                title: "NewTaxon.tf.habitat.placeholder".localized,
                systemImage: "leaf",
                prompt: "NewTaxon.tf.habitat.placeholder".localized,
                text: $viewModel.draft.habitat
            )

            FindingEditorField(
                title: "NewTaxon.tf.foundOn.placeholder".localized,
                systemImage: "magnifyingglass",
                prompt: "NewTaxon.tf.foundOn.placeholder".localized,
                text: $viewModel.draft.foundOn
            )

            Toggle(isOn: $viewModel.draft.isFoundDead) {
                Label("NewTaxon.tf.foundDead.text".localized, systemImage: "cross.case")
                    .font(.body.weight(.medium))
                    .foregroundColor(BiologerColors.textPrimary)
            }
            .tint(BiologerColors.accent)

            if viewModel.draft.isFoundDead {
                FindingEditorField(
                    title: "NewTaxon.tf.foundDead.placeholder".localized,
                    systemImage: "text.alignleft",
                    prompt: "NewTaxon.tf.foundDead.placeholder".localized,
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
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "checkmark.circle")
                }
                Text(
                    viewModel.isSaving
                        ? "FindingEditor.action.saving".localized
                        : "NewTaxon.btn.save.text".localized
                )
            }
        }
        .buttonStyle(BiologerActionButtonStyle())
        .disabled(viewModel.isBusy)
        .padding(.horizontal, BiologerSpacing.regular)
        .padding(.vertical, BiologerSpacing.small)
        .background(.ultraThinMaterial)
    }

    private var loadingView: some View {
        VStack(spacing: BiologerSpacing.regular) {
            ProgressView().controlSize(.large).tint(BiologerColors.accent)
            Text("FindingEditor.loading".localized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var failureView: some View {
        VStack(spacing: BiologerSpacing.regular) {
            Spacer()
            BiologerIconBadge(
                systemImage: "exclamationmark.arrow.triangle.2.circlepath",
                tint: BiologerColors.destructive,
                backgroundColor: BiologerColors.destructive.opacity(0.1),
                size: 64
            )
            Text("FindingEditor.loadError".localized)
                .font(.title3.weight(.semibold))
                .foregroundColor(BiologerColors.textPrimary)
                .multilineTextAlignment(.center)
            Button("ListOfFindings.retry".localized, action: viewModel.retryLoad)
                .buttonStyle(BiologerActionButtonStyle())
                .frame(maxWidth: 260)
            Spacer()
            Spacer()
        }
        .padding(BiologerSpacing.xLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            "NewTaxon.image.errorPopUp.title".localized
        case .validation, .saveFailure:
            "API.lb.error".localized
        case .saveSuccess:
            "FindingEditor.saveSuccess.title".localized
        }
    }

    private func alertMessage(_ alert: FindingEditorAlert) -> String {
        switch alert.kind {
        case .photoLimit:
            "NewTaxon.image.errorPopUp.description".localized
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
                "NewTaxon.popUpError.description.title.taxonNameRequired".localized
            case .individualCountRequired:
                "NewTaxon.popUpError.description.title.minimumNumberOfIndividualsIsOne".localized
            }
        }
    }
}
