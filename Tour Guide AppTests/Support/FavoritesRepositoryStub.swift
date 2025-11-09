import Foundation
@testable import Tour_Guide_App

final class FavoritesRepositoryStub: FavoritesRepository {
    var stored: Set<UUID>
    private(set) var saveCallCount = 0

    init(initial: Set<UUID> = []) {
        self.stored = initial
    }

    func loadFavorites() -> Set<UUID> {
        stored
    }

    func saveFavorites(_ ids: Set<UUID>) {
        stored = ids
        saveCallCount += 1
    }
}
