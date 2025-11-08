import Foundation
@testable import Tour_Guide_App

final class ThemeSettingsRepositoryStub: ThemeSettingsRepository {
    var storedSettings: ThemeSettings
    private(set) var saveCallCount = 0

    init(initial: ThemeSettings = .default) {
        self.storedSettings = initial
    }

    func loadSettings() -> ThemeSettings {
        storedSettings
    }

    func save(settings: ThemeSettings) {
        storedSettings = settings
        saveCallCount += 1
    }
}
