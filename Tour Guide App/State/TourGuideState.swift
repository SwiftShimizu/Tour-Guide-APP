import Foundation

struct TourGuideState: Equatable {
    var spots: [TourSpot] = []
    var isLoading = false
    var selectedSpot: TourSpot?
    var errorMessage: String?
    var lastUpdated: Date?
    var themeSettings: ThemeSettings = .default
    var userContents: [UUID: UserSpotContent] = [:]

    var hasContent: Bool {
        !spots.isEmpty
    }

    var favoritesCount: Int {
        spots.filter { $0.isFavorite }.count
    }

    func content(for spot: TourSpot) -> UserSpotContent {
        userContents[spot.id] ?? UserSpotContent.template(for: spot)
    }
}

enum TourGuideEffect: Equatable {
    case favoriteStatusChanged(name: String, isFavorite: Bool)
}
