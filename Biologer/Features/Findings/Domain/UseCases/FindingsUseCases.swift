struct FindingsUseCases {
    let list: ListOfFindingsUseCases
    let details: FindingDetailsUseCases
}

struct ListOfFindingsUseCases {
    let getFindings: GetFindingsUseCase
    let deleteFinding: DeleteFindingUseCase
    let deleteFindings: DeleteFindingsUseCase
    let deleteAllFindings: DeleteAllFindingsUseCase
    let uploadFindings: UploadFindingsUseCase
    let checkSubmissionAccess: CheckFindingSubmissionAccessUseCase
}

struct FindingDetailsUseCases {
    let getFindingDetails: GetFindingDetailsUseCase
    let uploadFindings: UploadFindingsUseCase
    let checkSubmissionAccess: CheckFindingSubmissionAccessUseCase
}
