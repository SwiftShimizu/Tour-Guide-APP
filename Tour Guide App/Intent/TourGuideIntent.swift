import Foundation
import Combine

@MainActor
final class TourGuideIntent: ObservableObject {
    enum IntentAction: Equatable {
        case loadSpots
        case retry
        case toggleFavorite(id: UUID)
        case selectSpot(TourSpot?)
        case dismissError
        case setThemeStyle(ThemeColorStyle)
        case setFontScale(FontScalePreference)
        case updateNote(spotID: UUID, text: String)
        case toggleChecklistItem(spotID: UUID, itemID: UUID)
        case addChecklistItem(spotID: UUID, title: String)
    }

    @Published private(set) var state: TourGuideState
    @Published var latestEffect: TourGuideEffect?

    private let reducer: TourGuideReducer
    private let repository: TourSpotRepository
    private let themeRepository: ThemeSettingsRepository
    private let favoritesRepository: FavoritesRepository
    private let userContentRepository: UserSpotContentRepository

    init(
        state: TourGuideState = TourGuideState(),
        reducer: TourGuideReducer = TourGuideReducer(),
        repository: TourSpotRepository = LocalTourSpotRepository(),
        themeRepository: ThemeSettingsRepository = UserDefaultsThemeSettingsRepository(),
        favoritesRepository: FavoritesRepository = UserDefaultsFavoritesRepository(),
        userContentRepository: UserSpotContentRepository = UserDefaultsUserSpotContentRepository()
    ) {
        self.state = state
        self.reducer = reducer
        self.repository = repository
        self.themeRepository = themeRepository
        self.favoritesRepository = favoritesRepository
        self.userContentRepository = userContentRepository
        self.state.themeSettings = themeRepository.loadSettings()
        self.state.userContents = userContentRepository.loadAll()
    }

    func handle(_ intent: IntentAction) async {
        switch intent {
        case .loadSpots, .retry:
            await loadSpots()
        case .toggleFavorite(let id):
            dispatch(.toggleFavorite(id))
            persistFavorites()
        case .selectSpot(let spot):
            dispatch(.selectSpot(spot))
        case .dismissError:
            dispatch(.setError(nil))
        case .setThemeStyle(let style):
            updateTheme { $0.colorStyle = style }
        case .setFontScale(let scale):
            updateTheme { $0.fontScale = scale }
        case let .updateNote(spotID, text):
            updateUserContent(spotID: spotID) { content, _ in
                content.updateNote(text)
            }
        case let .toggleChecklistItem(spotID, itemID):
            updateUserContent(spotID: spotID) { content, _ in
                content.toggleItem(id: itemID)
            }
        case let .addChecklistItem(spotID, title):
            updateUserContent(spotID: spotID) { content, _ in
                content.appendChecklist(title: title)
            }
        }
    }

    private func loadSpots() async {
        dispatch(.setLoading(true))
        do {
            let favorites = favoritesRepository.loadFavorites()
            let spots = try await repository.fetchSpots().map { spot -> TourSpot in
                var mutable = spot
                mutable.isFavorite = favorites.contains(spot.id)
                if mutable.reviews.isEmpty {
                    mutable.reviews = TourSpotReview.samples(for: mutable.name)
                }
                return mutable
            }
            dispatch(.spotsLoaded(spots, Date()))
            dispatch(.setLoading(false))
            dispatch(.setError(nil))
            refreshFavoritesIfNeeded()
        } catch {
            let message = error.localizedDescription.isEmpty ? "スポット情報を取得できませんでした。" : error.localizedDescription
            dispatch(.setError(message))
            dispatch(.setLoading(false))
        }
    }

    private func dispatch(_ action: TourGuideAction) {
        let effects = reducer.reduce(state: &state, action: action)
        if let lastEffect = effects.last {
            latestEffect = nil
            latestEffect = lastEffect
        }
    }

    private func updateTheme(_ update: (inout ThemeSettings) -> Void) {
        var settings = state.themeSettings
        update(&settings)
        themeRepository.save(settings: settings)
        dispatch(.setTheme(settings))
    }

    private func persistFavorites() {
        let ids = Set(state.spots.filter { $0.isFavorite }.map { $0.id })
        favoritesRepository.saveFavorites(ids)
    }

    private func refreshFavoritesIfNeeded() {
        let stored = favoritesRepository.loadFavorites()
        let ids = Set(state.spots.filter { $0.isFavorite }.map { $0.id })
        guard stored != ids else { return }
        favoritesRepository.saveFavorites(ids)
    }

    private func updateUserContent(spotID: UUID, mutation: (inout UserSpotContent, TourSpot) -> Void) {
        guard let spot = state.spots.first(where: { $0.id == spotID }) else { return }
        var content = state.userContents[spotID] ?? UserSpotContent.template(for: spot)
        mutation(&content, spot)
        userContentRepository.save(content: content, for: spotID)
        dispatch(.setUserContent(spotID: spotID, content: content))
    }
}
