import SwiftUI

extension ThemeColorStyle {
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark, .dusk:
            return .dark
        }
    }

    var tintColor: Color {
        switch self {
        case .system:
            return .accentColor
        case .light:
            return .orange
        case .dark:
            return .teal
        case .dusk:
            return .purple
        }
    }
}

extension FontScalePreference {
    var dynamicTypeSize: DynamicTypeSize {
        switch self {
        case .standard:
            return .large
        case .relaxed:
            return .xLarge
        case .large:
            return .accessibility3
        }
    }
}
