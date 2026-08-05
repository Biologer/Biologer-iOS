import Foundation

struct ObservationDataResponse: Decodable {
    let data: [ObservationResponse]

    struct ObservationResponse: Decodable {
        let id: Int
        let translations: [ObservationTranslationResponse]
    }

    struct ObservationTranslationResponse: Decodable {
        let id: Int
        let locale: String
        let name: String
    }
}
