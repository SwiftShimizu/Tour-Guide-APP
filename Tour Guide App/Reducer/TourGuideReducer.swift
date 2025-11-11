import Foundation

enum TourGuideAction: Equatable {
    case setLoading(Bool)
    case spotsLoaded([TourSpot], Date)
    case toggleFavorite(UUID)
    case selectSpot(TourSpot?)
    case setError(String?)
    case setTheme(ThemeSettings)
    case setUserContent(spotID: UUID, content: UserSpotContent)
}

struct TourGuideReducer {
    @discardableResult
    func reduce(state: inout TourGuideState, action: TourGuideAction) -> [TourGuideEffect] {
        switch action {
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            return []
        case let .spotsLoaded(spots, timestamp):
            state.spots = spots
            state.lastUpdated = timestamp
            state.errorMessage = nil
            return []
        case .toggleFavorite(let id):
            guard let index = state.spots.firstIndex(where: { $0.id == id }) else { return [] }
            state.spots[index].isFavorite.toggle()
            let spot = state.spots[index]
            if state.selectedSpot?.id == id {
                state.selectedSpot = spot
            }
            return [.favoriteStatusChanged(name: spot.name, isFavorite: spot.isFavorite)]
        case .selectSpot(let spot):
            state.selectedSpot = spot
            return []
        case .setError(let message):
            state.errorMessage = message
            return []
        case .setTheme(let settings):
            state.themeSettings = settings
            return []
        case let .setUserContent(spotID, content):
            state.userContents[spotID] = content
            if let selected = state.selectedSpot, selected.id == spotID {
                state.selectedSpot = state.spots.first(where: { $0.id == spotID })
            }
            return []
        }
    }
}
