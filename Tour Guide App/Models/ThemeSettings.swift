import Foundation

enum ThemeColorStyle: String, CaseIterable, Codable, Equatable, Identifiable {
    case system
    case light
    case dark
    case dusk

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "システムに合わせる"
        case .light: return "ライト"
        case .dark: return "ダーク"
        case .dusk: return "黄昏"
        }
    }

    var detail: String {
        switch self {
        case .system: return "端末の外観設定に追従"
        case .light: return "常に明るいテーマを使用"
        case .dark: return "常にダークテーマを使用"
        case .dusk: return "暖色ベースのリラックス配色"
        }
    }
}

enum FontScalePreference: String, CaseIterable, Codable, Equatable, Identifiable {
    case standard
    case relaxed
    case large

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: return "標準"
        case .relaxed: return "やや大きめ"
        case .large: return "特大"
        }
    }

    var sampleDescription: String {
        switch self {
        case .standard: return "デフォルトサイズで表示"
        case .relaxed: return "少し大きな文字で読みやすく"
        case .large: return "アクセシビリティを最優先"
        }
    }
}

struct ThemeSettings: Equatable, Codable {
    var colorStyle: ThemeColorStyle
    var fontScale: FontScalePreference

    init(colorStyle: ThemeColorStyle = .system, fontScale: FontScalePreference = .standard) {
        self.colorStyle = colorStyle
        self.fontScale = fontScale
    }

    static let `default` = ThemeSettings()
}
