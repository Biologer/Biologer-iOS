import SwiftUI
import UIKit

struct FindingSummaryRow: View {
    let finding: FindingSummary
    let isUploadSelectionActive: Bool
    let isSelectedForUpload: Bool
    let onSelect: () -> Void
    let onToggleUploadSelection: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: BiologerSpacing.xSmall) {
            Button(action: primaryAction) {
                HStack(spacing: BiologerSpacing.small) {
                    thumbnail
                    details

                    Spacer(minLength: BiologerSpacing.xxSmall)

                    trailingIndicator
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if !isUploadSelectionActive {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.body.weight(.semibold))
                        .foregroundColor(BiologerColors.destructive)
                        .frame(width: 36, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(
                    "ListOfFindings.deleteScreen.btn.delete".localized
                )
            }
        }
        .padding(BiologerSpacing.small)
        .biologerCard(
            isSelected: isUploadSelectionActive && isSelectedForUpload
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if !isUploadSelectionActive {
                Button(role: .destructive, action: onDelete) {
                    Label(
                        "ListOfFindings.deleteScreen.btn.delete".localized,
                        systemImage: "trash"
                    )
                }
            }
        }
    }

    @ViewBuilder
    private var trailingIndicator: some View {
        if isUploadSelectionActive {
            Image(
                systemName: isSelectedForUpload
                    ? "checkmark.circle.fill"
                    : "circle"
            )
            .font(.title3.weight(.semibold))
            .foregroundColor(
                isSelectedForUpload
                    ? BiologerColors.accent
                    : Color(uiColor: .tertiaryLabel)
            )
            .accessibilityLabel(
                isSelectedForUpload
                    ? "ListOfFindingsV2.selection.selected".localized
                    : "ListOfFindingsV2.selection.notSelected".localized
            )
        } else {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundColor(Color(uiColor: .tertiaryLabel))
        }
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.xSmall) {
            Text(displayedTaxonName)
                .font(.headline)
                .italic()
                .foregroundColor(BiologerColors.textPrimary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)

            HStack(spacing: BiologerSpacing.xSmall) {
                if !finding.developmentStageName.isEmpty {
                    FindingMetadataLabel(
                        title: finding.developmentStageName,
                        systemImage: "circle.hexagongrid"
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }

                statusBadge
            }
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if
            let data = finding.thumbnailData,
            let image = UIImage(data: data)
        {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 62, height: 62)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: BiologerRadius.control,
                        style: .continuous
                    )
                )
        } else {
            ZStack {
                RoundedRectangle(
                    cornerRadius: BiologerRadius.control,
                    style: .continuous
                )
                .fill(BiologerColors.iconBackground)

                Image(systemName: "leaf.fill")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(BiologerColors.brandStrong)
            }
            .frame(width: 62, height: 62)
        }
    }

    private var statusBadge: some View {
        let isUploaded = finding.uploadStatus == .uploaded
        return FindingMetadataLabel(
            title: isUploaded
                ? "ListOfFindingsV2.status.uploaded".localized
                : "ListOfFindingsV2.status.pending".localized,
            systemImage: isUploaded
                ? "checkmark.circle.fill"
                : "icloud.and.arrow.up"
        )
        .font(.caption2.weight(.semibold))
        .foregroundColor(
            isUploaded ? BiologerColors.brandStrong : Color.orange
        )
        .padding(.horizontal, BiologerSpacing.xSmall)
        .padding(.vertical, BiologerSpacing.xxSmall)
        .background(
            isUploaded
                ? BiologerColors.selectedSurface
                : Color.orange.opacity(0.12),
            in: Capsule()
        )
        .lineLimit(1)
    }

    private var displayedTaxonName: String {
        finding.taxonName.isEmpty ? "-" : finding.taxonName
    }

    private func primaryAction() {
        if isUploadSelectionActive {
            onToggleUploadSelection()
        } else {
            onSelect()
        }
    }
}
