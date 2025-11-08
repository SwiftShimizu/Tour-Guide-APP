import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var themeSettings: ThemeSettings

    var themeTitle: String { themeSettings.colorStyle.title }
    var themeDetail: String { themeSettings.colorStyle.detail }
    var fontTitle: String { themeSettings.fontScale.title }
    var fontDetail: String { themeSettings.fontScale.sampleDescription }
    var selectedColorStyle: ThemeColorStyle { themeSettings.colorStyle }
    var selectedFontScale: FontScalePreference { themeSettings.fontScale }

    private let intent: TourGuideIntent
    private var cancellables = Set<AnyCancellable>()

    init(intent: TourGuideIntent) {
        self.intent = intent
        self.themeSettings = intent.state.themeSettings

        intent.$state
            .map(\.themeSettings)
            .removeDuplicates()
            .sink { [weak self] settings in
                self?.themeSettings = settings
            }
            .store(in: &cancellables)
    }

    func selectTheme(_ style: ThemeColorStyle) {
        guard style != themeSettings.colorStyle else { return }
        Task { await intent.handle(.setThemeStyle(style)) }
    }

    func selectFontScale(_ scale: FontScalePreference) {
        guard scale != themeSettings.fontScale else { return }
        Task { await intent.handle(.setFontScale(scale)) }
    }
}
