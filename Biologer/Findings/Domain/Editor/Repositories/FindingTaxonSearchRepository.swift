protocol FindingTaxonSearchRepository {
    func search(query: String, limit: Int) throws -> [FindingEditorTaxon]
}
