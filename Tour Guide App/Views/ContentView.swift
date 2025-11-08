import SwiftUI

struct ContentView: View {
    @StateObject private var intent = TourGuideIntent()
    @State private var favoriteToastMessage: String?
    @State private var settingsDestination: SettingsDestination?

    var body: some View {
        NavigationStack {
            Group {
                if intent.state.isLoading && !intent.state.hasContent {
                    ProgressView("スポットを読み込み中…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if intent.state.hasContent {
                    spotsList
                } else {
                    EmptyStateView(retryAction: {
                        Task { await intent.handle(.retry) }
                    })
                }
            }
            .navigationTitle("Tour Guide")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        settingsDestination = .root
                    } label: {
                        Label("設定", systemImage: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await intent.handle(.retry) }
                    } label: {
                        if intent.state.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .accessibilityLabel("最新の情報に更新")
                    .disabled(intent.state.isLoading)
                }
            }
            .navigationDestination(item: selectedSpotBinding) { spot in
                TourSpotDetailView(
                    spot: spot,
                    onToggleFavorite: {
                        Task { await intent.handle(.toggleFavorite(id: spot.id)) }
                    }
                )
            }
            .navigationDestination(item: $settingsDestination) { destination in
                switch destination {
                case .root:
                    SettingsRootView(intent: intent)
                }
            }
        }
        .task {
            await intent.handle(.loadSpots)
        }
        .alert("読み込みエラー", isPresented: errorBinding) {
            Button("閉じる", role: .cancel) {
                Task { await intent.handle(.dismissError) }
            }
            Button("再試行") {
                Task {
                    await intent.handle(.dismissError)
                    await intent.handle(.retry)
                }
            }
        } message: {
            Text(intent.state.errorMessage ?? "不明なエラーが発生しました")
        }
        .overlay(alignment: .bottom) {
            if let message = favoriteToastMessage {
                FavoriteToastView(message: message)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 12)
            }
        }
        .onChange(of: intent.latestEffect) { _, effect in
            guard let effect else { return }
            switch effect {
            case let .favoriteStatusChanged(name, isFavorite):
                let message = "\(name)を" + (isFavorite ? "お気に入りに追加しました" : "お気に入りから外しました")
                withAnimation {
                    favoriteToastMessage = message
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    if favoriteToastMessage == message {
                        withAnimation {
                            favoriteToastMessage = nil
                        }
                    }
                }
            }
        }
        .tint(themeTintColor)
        .preferredColorScheme(preferredColorScheme)
        .environment(\.dynamicTypeSize, intent.state.themeSettings.fontScale.dynamicTypeSize)
    }

    private var spotsList: some View {
        List(intent.state.spots) { spot in
            Button {
                Task { await intent.handle(.selectSpot(spot)) }
            } label: {
                TourSpotRowView(spot: spot, tintColor: themeTintColor)
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing) {
                Button {
                    Task { await intent.handle(.toggleFavorite(id: spot.id)) }
                } label: {
                    Label(spot.isFavorite ? "解除" : "追加", systemImage: spot.isFavorite ? "heart.slash" : "heart.fill")
                }
                .tint(spot.isFavorite ? .gray : .pink)
            }
        }
        .animation(.default, value: intent.state.spots)
        .listStyle(.plain)
    }

    private var selectedSpotBinding: Binding<TourSpot?> {
        Binding<TourSpot?>(
            get: { intent.state.selectedSpot },
            set: { newValue in
                Task { await intent.handle(.selectSpot(newValue)) }
            }
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding<Bool>(
            get: { intent.state.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    Task { await intent.handle(.dismissError) }
                }
            }
        )
    }
}

private struct TourSpotRowView: View {
    let spot: TourSpot
    let tintColor: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(tintColor.opacity(0.2))
                Image(systemName: spot.heroImageName.isEmpty ? "globe.asia.australia.fill" : spot.heroImageName)
                    .font(.title2)
                    .foregroundStyle(tintColor)
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.headline)
                Text(spot.locationDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(spot.shortHighlights)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(spot.isFavorite ? .pink : .secondary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 8)
    }
}

private struct EmptyStateView: View {
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("まだスポットがありません")
                .font(.headline)
            Text("[再試行]をタップしてローカルデータを読み込んでください。")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("再試行", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct FavoriteToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.footnote)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(radius: 4)
            .padding(.horizontal)
    }
}

private extension ContentView {
    var preferredColorScheme: ColorScheme? {
        intent.state.themeSettings.colorStyle.colorScheme
    }

    var themeTintColor: Color {
        intent.state.themeSettings.colorStyle.tintColor
    }
}

private enum SettingsDestination: Identifiable {
    case root

    var id: Int {
        switch self {
        case .root: return 0
        }
    }
}

private extension ThemeColorStyle {
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

private extension FontScalePreference {
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

#Preview {
    ContentView()
}
