import Foundation

struct TourGuideState: Equatable {
    var spots: [TourSpot] = []
    var isLoading = false
    var selectedSpot: TourSpot?
    var errorMessage: String?
    var lastUpdated: Date?
    var themeSettings: ThemeSettings = .default

    var hasContent: Bool {
        !spots.isEmpty
    }

    var favoritesCount: Int {
        spots.filter { $0.isFavorite }.count
    }
}

enum TourGuideEffect: Equatable {
    case favoriteStatusChanged(name: String, isFavorite: Bool)
}
