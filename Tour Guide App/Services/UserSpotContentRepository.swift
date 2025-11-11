import Foundation

protocol UserSpotContentRepository {
    func loadAll() -> [UUID: UserSpotContent]
    func save(content: UserSpotContent, for spotID: UUID)
}

struct UserDefaultsUserSpotContentRepository: UserSpotContentRepository {
    private let defaults: UserDefaults
    private let storageKey = "user_spot_content"
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func loadAll() -> [UUID: UserSpotContent] {
        guard let data = defaults.data(forKey: storageKey) else {
            return [:]
        }
        do {
            let raw = try decoder.decode([String: UserSpotContent].self, from: data)
            var mapped: [UUID: UserSpotContent] = [:]
            for (key, value) in raw {
                if let id = UUID(uuidString: key) {
                    mapped[id] = value
                }
            }
            return mapped
        } catch {
            return [:]
        }
    }

    func save(content: UserSpotContent, for spotID: UUID) {
        var all = loadAll()
        all[spotID] = content
        guard let data = encode(map: all) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func encode(map: [UUID: UserSpotContent]) -> Data? {
        let raw = Dictionary(uniqueKeysWithValues: map.map { ($0.key.uuidString, $0.value) })
        return try? encoder.encode(raw)
    }
}
