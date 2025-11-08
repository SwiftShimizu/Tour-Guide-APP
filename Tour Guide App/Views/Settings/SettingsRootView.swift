import SwiftUI

struct SettingsRootView: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("テーマ") {
                NavigationLink {
                    ThemeSelectionView(viewModel: viewModel)
                } label: {
                    SettingsRow(
                        title: "テーマカラー",
                        detail: viewModel.themeTitle,
                        caption: viewModel.themeDetail
                    )
                }
            }

            Section("表示") {
                NavigationLink {
                    FontScaleSettingsView(viewModel: viewModel)
                } label: {
                    SettingsRow(
                        title: "文字サイズ",
                        detail: viewModel.fontTitle,
                        caption: viewModel.fontDetail
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
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section(header: Text("テーマ"), footer: Text("選択したテーマはアプリ全体に即時反映されます")) {
                ForEach(ThemeColorStyle.allCases) { style in
                    Button {
                        viewModel.selectTheme(style)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(style.title)
                                Text(style.detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if style == viewModel.selectedColorStyle {
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
    @ObservedObject var viewModel: SettingsViewModel

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
            get: { viewModel.selectedFontScale },
            set: { newValue in viewModel.selectFontScale(newValue) }
        )
    }
}
