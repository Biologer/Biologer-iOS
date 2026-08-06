import SwiftUI

struct FindingsOverviewCard: View {
    let findings: [FindingSummary]
    let selectedFilter: FindingsListFilter
    let isFilterInteractionEnabled: Bool
    let onSelectFilter: (FindingsListFilter) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.regular) {
            header

            HStack(spacing: BiologerSpacing.xSmall) {
                metric(
                    filter: .all,
                    title: "ListOfFindings.summary.total".localized,
                    value: findings.count,
                    systemImage: "list.bullet"
                )
                metric(
                    filter: .uploaded,
                    title: "ListOfFindings.status.uploaded".localized,
                    value: uploadedFindingsCount,
                    systemImage: "checkmark.circle.fill"
                )
                metric(
                    filter: .pending,
                    title: "ListOfFindings.status.pending".localized,
                    value: findings.count - uploadedFindingsCount,
                    systemImage: "icloud.and.arrow.up"
                )
            }
        }
        .padding(BiologerSpacing.regular)
        .biologerHeroCard()
    }

    private var header: some View {
        HStack(spacing: BiologerSpacing.small) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: "leaf.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                Text("ListOfFindings.summary.title".localized.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.78))
                    .tracking(0.5)

                Text("Findings.title".localized)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
            }

            Spacer(minLength: BiologerSpacing.xSmall)

            Text("\(findings.count)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    private func metric(
        filter: FindingsListFilter,
        title: String,
        value: Int,
        systemImage: String
    ) -> some View {
        let isSelected = selectedFilter == filter

        return Button(action: { onSelectFilter(filter) }) {
            VStack(alignment: .leading, spacing: BiologerSpacing.xxSmall) {
                FindingMetadataLabel(
                    title: title,
                    systemImage: systemImage
                )
                .font(.caption2.weight(.medium))
                .lineLimit(1)

                Text("\(value)")
                    .font(.headline.weight(.bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, BiologerSpacing.xSmall)
            .padding(.vertical, BiologerSpacing.xSmall)
            .background(
                .white.opacity(isSelected ? 0.3 : 0.15),
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
                .stroke(
                    .white.opacity(isSelected ? 0.72 : 0),
                    lineWidth: 1.5
                )
            }
            .scaleEffect(isSelected ? 1 : 0.98)
        }
        .buttonStyle(.plain)
        .disabled(!isFilterInteractionEnabled)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.easeOut(duration: 0.18), value: isSelected)
    }

    private var uploadedFindingsCount: Int {
        findings.filter { $0.uploadStatus == .uploaded }.count
    }
}
