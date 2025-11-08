import SwiftUI

struct SettingsRootView: View {
    @ObservedObject var intent: TourGuideIntent

    var body: some View {
        List {
            Section("テーマ") {
                NavigationLink {
                    ThemeSelectionView(intent: intent)
                } label: {
                    SettingsRow(
                        title: "テーマカラー",
                        detail: intent.state.themeSettings.colorStyle.title,
                        caption: intent.state.themeSettings.colorStyle.detail
                    )
                }
            }

            Section("表示") {
                NavigationLink {
                    FontScaleSettingsView(intent: intent)
                } label: {
                    SettingsRow(
                        title: "文字サイズ",
                        detail: intent.state.themeSettings.fontScale.title,
                        caption: intent.state.themeSettings.fontScale.sampleDescription
                    )
                }
            }
        }
        .navigationTitle("設定")
    }
}

private struct SettingsRow: View {
    let title: String
    let detail: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(detail)
                    .foregroundStyle(.secondary)
            }
            Text(caption)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ThemeSelectionView: View {
    @ObservedObject var intent: TourGuideIntent

    var body: some View {
        List {
            Section(header: Text("テーマ"), footer: Text("選択したテーマはアプリ全体に即時反映されます")) {
                ForEach(ThemeColorStyle.allCases) { style in
                    Button {
                        Task { await intent.handle(.setThemeStyle(style)) }
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(style.title)
                                Text(style.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if style == intent.state.themeSettings.colorStyle {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("テーマカラー")
    }
}

struct FontScaleSettingsView: View {
    @ObservedObject var intent: TourGuideIntent

    var body: some View {
        List {
            Section(header: Text("文字サイズ")) {
                Picker("文字サイズ", selection: selectionBinding) {
                    ForEach(FontScalePreference.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("プレビュー") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("旅の計画がもっと楽しく")
                        .font(.title3)
                    Text("フォントサイズを変えると、アプリ全体の文字が即座に切り替わります。自分にとって読みやすい大きさを選んでください。")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("表示設定")
    }

    private var selectionBinding: Binding<FontScalePreference> {
        Binding(
            get: { intent.state.themeSettings.fontScale },
            set: { newValue in Task { await intent.handle(.setFontScale(newValue)) } }
        )
    }
}
