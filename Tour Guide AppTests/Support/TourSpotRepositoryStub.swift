import Foundation
@testable import Tour_Guide_App

final class TourSpotRepositoryStub: TourSpotRepository {
    var result: Result<[TourSpot], Error>

    init(result: Result<[TourSpot], Error>) {
        self.result = result
    }

    func fetchSpots() async throws -> [TourSpot] {
        switch result {
        case .success(let spots):
            return spots
        case .failure(let error):
            throw error
        }
    }
}
