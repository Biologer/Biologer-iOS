import SwiftUI

struct FindingDetailsScreenV2: View {
    @StateObject private var viewModel: FindingDetailsV2ViewModel

    init(viewModel: FindingDetailsV2ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .biologerPageBackground()
            .navigationTitle("FindingDetailsV2.nav.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .tint(BiologerColors.accent)
            .onAppear(perform: viewModel.loadDetails)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadState {
        case .idle, .loading:
            loadingView
        case .content:
            if let details = viewModel.details {
                detailsContent(details)
            } else {
                failureView
            }
        case .failure:
            failureView
        }
    }

    private func detailsContent(_ details: FindingDetails) -> some View {
        ScrollView {
            LazyVStack(spacing: BiologerSpacing.large) {
                FindingDetailsHero(details: details)

                if details.photos.count > 1 {
                    FindingDetailsPhotoGallery(photos: details.photos)
                }

                overviewSection(details)

                if let location = details.location {
                    locationSection(location)
                }

                if !details.individuals.isEmpty {
                    individualsSection(details.individuals)
                }

                if !details.observations.isEmpty {
                    observationsSection(details.observations)
                }

                if containsNotes(details) {
                    notesSection(details)
                }
            }
            .padding(.horizontal, BiologerSpacing.regular)
            .padding(.top, BiologerSpacing.small)
            .padding(.bottom, BiologerSpacing.xxLarge)
        }
        .safeAreaInset(edge: .bottom) {
            editButton
        }
    }

    private func overviewSection(_ details: FindingDetails) -> some View {
        FindingDetailsSection(
            title: "FindingDetailsV2.section.details".localized,
            systemImage: "doc.text.magnifyingglass"
        ) {
            FindingDetailsInfoRow(
                title: "FindingDetailsV2.field.date".localized,
                value: details.createdAt.formatted(date: .abbreviated, time: .shortened),
                systemImage: "calendar"
            )

            if let developmentStageName = details.developmentStageName {
                FindingDetailsDivider()
                FindingDetailsInfoRow(
                    title: "NewTaxon.tf.developmentStage.placeholder".localized,
                    value: developmentStageName,
                    systemImage: "circle.hexagongrid"
                )
            }

            if let atlasCodeName = details.atlasCodeName {
                FindingDetailsDivider()
                FindingDetailsInfoRow(
                    title: "NewTaxon.tf.nesting.placeholder".localized,
                    value: atlasCodeName,
                    systemImage: "bird"
                )
            }
        }
    }

    private func locationSection(_ location: FindingDetailsLocation) -> some View {
        FindingDetailsSection(
            title: "FindingDetailsV2.section.location".localized,
            systemImage: "location"
        ) {
            FindingDetailsInfoRow(
                title: "NewTaxon.lb.latitude".localized,
                value: coordinate(location.latitude),
                systemImage: "arrow.up.and.down"
            )

            FindingDetailsDivider()

            FindingDetailsInfoRow(
                title: "NewTaxon.lb.longitued".localized,
                value: coordinate(location.longitude),
                systemImage: "arrow.left.and.right"
            )

            FindingDetailsDivider()

            FindingDetailsInfoRow(
                title: "NewTaxon.lb.altitude".localized,
                value: meters(location.altitude),
                systemImage: "mountain.2"
            )

            FindingDetailsDivider()

            FindingDetailsInfoRow(
                title: "NewTaxon.lb.accuracyTitle".localized,
                value: meters(location.accuracy),
                systemImage: "scope"
            )

            FindingDetailsDivider()

            Button(action: viewModel.didTapShowLocation) {
                HStack(spacing: BiologerSpacing.xSmall) {
                    Image(systemName: "map")
                    Text("FindingDetailsV2.action.showOnMap".localized)
                }
            }
            .buttonStyle(
                BiologerActionButtonStyle(
                    isFilled: false
                )
            )
            .padding(BiologerSpacing.regular)
        }
    }

    private func individualsSection(
        _ individuals: FindingDetailsIndividuals
    ) -> some View {
        FindingDetailsSection(
            title: "FindingDetailsV2.section.individuals".localized,
            systemImage: "number"
        ) {
            if let total = individuals.total {
                FindingDetailsInfoRow(
                    title: "NewTaxon.tf.individual.placeholder".localized,
                    value: String(total),
                    systemImage: "sum"
                )
            }

            if individuals.total != nil && individuals.male != nil {
                FindingDetailsDivider()
            }

            if let male = individuals.male {
                FindingDetailsInfoRow(
                    title: "NewTaxon.tf.maleIndividual.placeholder".localized,
                    value: String(male),
                    systemImage: "person"
                )
            }

            if (individuals.total != nil || individuals.male != nil), individuals.female != nil {
                FindingDetailsDivider()
            }

            if let female = individuals.female {
                FindingDetailsInfoRow(
                    title: "NewTaxon.tf.femaleIndividual.placeholder".localized,
                    value: String(female),
                    systemImage: "person.fill"
                )
            }
        }
    }

    private func observationsSection(_ observations: [String]) -> some View {
        FindingDetailsSection(
            title: "FindingDetailsV2.section.observations".localized,
            systemImage: "eye"
        ) {
            ForEach(Array(observations.enumerated()), id: \.offset) { index, observation in
                if index > 0 {
                    FindingDetailsDivider()
                }

                FindingDetailsInfoRow(
                    title: "FindingDetailsV2.section.observations".localized,
                    value: observation,
                    systemImage: "checkmark.circle"
                )
            }
        }
    }

    private func notesSection(_ details: FindingDetails) -> some View {
        FindingDetailsSection(
            title: "FindingDetailsV2.section.notes".localized,
            systemImage: "note.text"
        ) {
            noteRows(details)
        }
    }

    @ViewBuilder
    private func noteRows(_ details: FindingDetails) -> some View {
        let rows = noteValues(details)

        ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
            if index > 0 {
                FindingDetailsDivider()
            }

            FindingDetailsTextRow(
                title: row.title,
                value: row.value,
                systemImage: row.systemImage
            )
        }
    }

    private var editButton: some View {
        Button(action: viewModel.didTapEdit) {
            HStack(spacing: BiologerSpacing.xSmall) {
                Image(systemName: "pencil")
                Text("FindingDetailsV2.action.edit".localized)
            }
        }
        .buttonStyle(BiologerActionButtonStyle())
        .padding(.horizontal, BiologerSpacing.regular)
        .padding(.vertical, BiologerSpacing.small)
        .background(.ultraThinMaterial)
    }

    private var loadingView: some View {
        VStack(spacing: BiologerSpacing.regular) {
            ProgressView()
                .controlSize(.large)
                .tint(BiologerColors.accent)

            Text("FindingDetailsV2.loading".localized)
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

            VStack(spacing: BiologerSpacing.xSmall) {
                Text("FindingDetailsV2.loadError.title".localized)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(BiologerColors.textPrimary)

                Text("FindingDetailsV2.loadError.message".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(
                "ListOfFindingsV2.retry".localized,
                action: viewModel.loadDetails
            )
            .buttonStyle(BiologerActionButtonStyle())
            .frame(maxWidth: 260)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(BiologerSpacing.xLarge)
    }

    private func containsNotes(_ details: FindingDetails) -> Bool {
        !noteValues(details).isEmpty
    }

    private func noteValues(_ details: FindingDetails) -> [FindingNoteValue] {
        [
            details.comment.map {
                FindingNoteValue(
                    title: "NewTaxon.tf.comment.placeholder".localized,
                    value: $0,
                    systemImage: "text.bubble"
                )
            },
            details.habitat.map {
                FindingNoteValue(
                    title: "NewTaxon.tf.habitat.placeholder".localized,
                    value: $0,
                    systemImage: "leaf"
                )
            },
            details.foundOn.map {
                FindingNoteValue(
                    title: "NewTaxon.tf.foundOn.placeholder".localized,
                    value: $0,
                    systemImage: "magnifyingglass"
                )
            },
            details.foundDead.map {
                FindingNoteValue(
                    title: "NewTaxon.tf.foundDead.placeholder".localized,
                    value: $0,
                    systemImage: "cross.case"
                )
            }
        ]
        .compactMap { $0 }
    }

    private func coordinate(_ value: Double) -> String {
        String(format: "%.5f", value)
    }

    private func meters(_ value: Double) -> String {
        String(format: "%.1f m", value)
    }
}

private struct FindingNoteValue {
    let title: String
    let value: String
    let systemImage: String
}
