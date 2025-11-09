import SwiftUI

struct ContentView: View {
    @StateObject private var intent: TourGuideIntent
    @StateObject private var settingsViewModel: SettingsViewModel
    @State private var favoriteToastMessage: String?
    @State private var settingsDestination: SettingsDestination?

    init() {
        let intent = TourGuideIntent()
        _intent = StateObject(wrappedValue: intent)
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(intent: intent))
    }

    @ViewBuilder
    private var mainContent: some View {
        if intent.state.isLoading && !intent.state.hasContent {
            ProgressView("スポットを読み込み中…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if intent.state.hasContent {
            HomeSpotListView(
                spots: intent.state.spots,
                tintColor: themeTintColor,
                onSelect: { spot in Task { await intent.handle(.selectSpot(spot)) } },
                onToggleFavorite: { id in Task { await intent.handle(.toggleFavorite(id: id)) } }
            )
        } else {
            HomeEmptyStateView(retryAction: { Task { await intent.handle(.retry) } })
        }
    }

    @ViewBuilder
    private var settingsButton: some View {
        Button {
            settingsDestination = .root
        } label: {
            Label("設定", systemImage: "gearshape")
        }
    }

    @ViewBuilder
    private var refreshButton: some View {
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

    var body: some View {
        NavigationStack {
            mainContent
            .navigationTitle("Tour Guide")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    settingsButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    refreshButton
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
                    SettingsRootView(viewModel: settingsViewModel)
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
        .environment(\.dynamicTypeSize, settingsViewModel.themeSettings.fontScale.dynamicTypeSize)
    }

    private var preferredColorScheme: ColorScheme? {
        settingsViewModel.themeSettings.colorStyle.colorScheme
    }

    private var themeTintColor: Color {
        settingsViewModel.themeSettings.colorStyle.tintColor
    }

    private var selectedSpotBinding: Binding<TourSpot?> {
        Binding<TourSpot?>(
            get: { intent.state.selectedSpot },
            set: { (newValue: TourSpot?) in
                Task { await intent.handle(.selectSpot(newValue)) }
            }
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding<Bool>(
            get: { intent.state.errorMessage != nil },
            set: { (isPresented: Bool) in
                if !isPresented {
                    Task { await intent.handle(.dismissError) }
                }
            }
        )
    }
}

private enum SettingsDestination: Identifiable {
    case root

    var id: Int {
        switch self {
        case .root:
            return 0
        }
    }
}

#Preview {
    ContentView()
}
