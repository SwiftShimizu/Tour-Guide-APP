import Foundation

protocol ThemeSettingsRepository {
    func loadSettings() -> ThemeSettings
    func save(settings: ThemeSettings)
}

struct UserDefaultsThemeSettingsRepository: ThemeSettingsRepository {
    private let defaults: UserDefaults
    private let storageKey = "theme_settings"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSettings() -> ThemeSettings {
        guard
            let data = defaults.data(forKey: storageKey),
            let settings = try? JSONDecoder().decode(ThemeSettings.self, from: data)
        else {
            return .default
        }
        return settings
    }

    func save(settings: ThemeSettings) {
        guard let data = try? JSONEncoder().encode(settings) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
