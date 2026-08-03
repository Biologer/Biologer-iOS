import SwiftUI

struct FindingsOverviewCard: View {
    let findings: [FindingSummary]

    var body: some View {
        VStack(alignment: .leading, spacing: BiologerSpacing.regular) {
            header

            HStack(spacing: BiologerSpacing.xSmall) {
                metric(
                    title: "ListOfFindingsV2.summary.total".localized,
                    value: findings.count,
                    systemImage: "list.bullet"
                )
                metric(
                    title: "ListOfFindingsV2.status.uploaded".localized,
                    value: uploadedFindingsCount,
                    systemImage: "checkmark.circle.fill"
                )
                metric(
                    title: "ListOfFindingsV2.status.pending".localized,
                    value: findings.count - uploadedFindingsCount,
                    systemImage: "icloud.and.arrow.up"
                )
            }
        }
        .padding(BiologerSpacing.regular)
        .background(
            LinearGradient(
                colors: [
                    BiologerColors.brandStrong,
                    BiologerColors.accent
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(
                cornerRadius: BiologerRadius.hero,
                style: .continuous
            )
        )
        .shadow(
            color: BiologerColors.brandStrong.opacity(0.24),
            radius: 12,
            y: 6
        )
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
                Text("ListOfFindingsV2.summary.title".localized.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.78))
                    .tracking(0.5)

                Text("SideMenu.lb.listOfFindings".localized)
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
        title: String,
        value: Int,
        systemImage: String
    ) -> some View {
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
            .white.opacity(0.15),
            in: RoundedRectangle(
                cornerRadius: BiologerRadius.control,
                style: .continuous
            )
        )
    }

    private var uploadedFindingsCount: Int {
        findings.filter { $0.uploadStatus == .uploaded }.count
    }
}
