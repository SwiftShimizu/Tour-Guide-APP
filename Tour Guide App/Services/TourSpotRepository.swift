import Foundation

protocol TourSpotRepository {
    func fetchSpots() async throws -> [TourSpot]
}

enum TourSpotRepositoryError: Error, LocalizedError {
    case missingSeedData
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .missingSeedData:
            return "ローカルデータが見つかりませんでした。"
        case .decodingFailed:
            return "観光スポットデータの読み込みに失敗しました。"
        }
    }
}

struct LocalTourSpotRepository: TourSpotRepository {
    private let decoder = JSONDecoder()

    func fetchSpots() async throws -> [TourSpot] {
        try await Task.sleep(for: .milliseconds(150))

        if let jsonURL = Bundle.main.url(forResource: "tour_spots", withExtension: "json") {
            let data = try Data(contentsOf: jsonURL)
            do {
                return try decoder.decode([TourSpot].self, from: data)
            } catch {
                throw TourSpotRepositoryError.decodingFailed
            }
        }

        guard !TourSpot.mockSpots.isEmpty else {
            throw TourSpotRepositoryError.missingSeedData
        }
        return TourSpot.mockSpots
    }
}
