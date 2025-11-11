import Foundation
@testable import Tour_Guide_App

final class UserSpotContentRepositoryStub: UserSpotContentRepository {
    var storage: [UUID: UserSpotContent]
    private(set) var saveCallArgs: [(UUID, UserSpotContent)] = []

    init(initial: [UUID: UserSpotContent] = [:]) {
        self.storage = initial
    }

    func loadAll() -> [UUID: UserSpotContent] {
        storage
    }

    func save(content: UserSpotContent, for spotID: UUID) {
        storage[spotID] = content
        saveCallArgs.append((spotID, content))
    }
}
