import Foundation

protocol FavoritesRepository {
    func loadFavorites() -> Set<UUID>
    func saveFavorites(_ ids: Set<UUID>)
}

struct UserDefaultsFavoritesRepository: FavoritesRepository {
    private let defaults: UserDefaults
    private let storageKey = "favorite_spot_ids"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadFavorites() -> Set<UUID> {
        guard let data = defaults.array(forKey: storageKey) as? [String] else {
            return []
        }
        return Set(data.compactMap(UUID.init))
    }

    func saveFavorites(_ ids: Set<UUID>) {
        let raw = ids.map { $0.uuidString }
        defaults.set(raw, forKey: storageKey)
    }
}
