enum FindingsListFilter: CaseIterable, Equatable {
    case all
    case uploaded
    case pending

    func includes(_ finding: FindingSummary) -> Bool {
        switch self {
        case .all:
            true
        case .uploaded:
            finding.uploadStatus == .uploaded
        case .pending:
            finding.uploadStatus == .pending
        }
    }
}
