import XCTest
@testable import Tour_Guide_App

@MainActor
final class TourGuideIntentTests: XCTestCase {
    func testHandleLoadSpotsUpdatesState() async {
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let themeRepository = ThemeSettingsRepositoryStub()
        let favoritesRepository = FavoritesRepositoryStub()
        let intent = TourGuideIntent(
            repository: repository,
            themeRepository: themeRepository,
            favoritesRepository: favoritesRepository,
            userContentRepository: UserSpotContentRepositoryStub()
        )

        await intent.handle(.loadSpots)

        XCTAssertFalse(intent.state.spots.isEmpty)
        XCTAssertFalse(intent.state.isLoading)
        XCTAssertNil(intent.state.errorMessage)
    }

    func testHandleLoadSpotsFailureSetsError() async {
        enum StubError: Error { case failed }
        let repository = TourSpotRepositoryStub(result: .failure(StubError.failed))
        let themeRepository = ThemeSettingsRepositoryStub()
        let favoritesRepository = FavoritesRepositoryStub()
        let intent = TourGuideIntent(
            repository: repository,
            themeRepository: themeRepository,
            favoritesRepository: favoritesRepository,
            userContentRepository: UserSpotContentRepositoryStub()
        )

        await intent.handle(.loadSpots)

        XCTAssertTrue(intent.state.spots.isEmpty)
        XCTAssertFalse(intent.state.isLoading)
        XCTAssertNotNil(intent.state.errorMessage)
    }

    func testToggleFavoriteViaIntentUpdatesState() async {
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let themeRepository = ThemeSettingsRepositoryStub()
        let favoritesRepository = FavoritesRepositoryStub()
        let intent = TourGuideIntent(
            repository: repository,
            themeRepository: themeRepository,
            favoritesRepository: favoritesRepository,
            userContentRepository: UserSpotContentRepositoryStub()
        )
        await intent.handle(.loadSpots)
        let target = intent.state.spots[0]

        await intent.handle(.toggleFavorite(id: target.id))

        XCTAssertEqual(intent.state.spots[0].isFavorite, !target.isFavorite)
    }

    func testIntentLoadsThemeFromRepository() async {
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let themeSettings = ThemeSettings(colorStyle: .dusk, fontScale: .relaxed)
        let themeRepository = ThemeSettingsRepositoryStub(initial: themeSettings)

        let intent = TourGuideIntent(
            repository: repository,
            themeRepository: themeRepository,
            favoritesRepository: FavoritesRepositoryStub(),
            userContentRepository: UserSpotContentRepositoryStub()
        )

        XCTAssertEqual(intent.state.themeSettings, themeSettings)
    }

    func testThemeUpdatesPersistViaIntent() async {
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let themeRepository = ThemeSettingsRepositoryStub()
        let intent = TourGuideIntent(
            repository: repository,
            themeRepository: themeRepository,
            favoritesRepository: FavoritesRepositoryStub(),
            userContentRepository: UserSpotContentRepositoryStub()
        )

        await intent.handle(.setThemeStyle(.dark))
        await intent.handle(.setFontScale(.large))

        XCTAssertEqual(intent.state.themeSettings.colorStyle, .dark)
        XCTAssertEqual(intent.state.themeSettings.fontScale, .large)
        XCTAssertEqual(themeRepository.storedSettings.fontScale, .large)
        XCTAssertEqual(themeRepository.saveCallCount, 2)
    }

    func testFavoritesLoadedFromRepository() async {
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let favoriteID = TourSpot.mockSpots[1].id
        let favoritesRepository = FavoritesRepositoryStub(initial: Set([favoriteID]))
        let intent = TourGuideIntent(
            repository: repository,
            themeRepository: ThemeSettingsRepositoryStub(),
            favoritesRepository: favoritesRepository,
            userContentRepository: UserSpotContentRepositoryStub()
        )

        await intent.handle(.loadSpots)

        XCTAssertTrue(intent.state.spots[1].isFavorite)
    }

    func testFavoriteTogglePersists() async {
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let favoritesRepository = FavoritesRepositoryStub()
        let intent = TourGuideIntent(
            repository: repository,
            themeRepository: ThemeSettingsRepositoryStub(),
            favoritesRepository: favoritesRepository,
            userContentRepository: UserSpotContentRepositoryStub()
        )
        await intent.handle(.loadSpots)
        let target = intent.state.spots[0]

        await intent.handle(.toggleFavorite(id: target.id))

        XCTAssertEqual(favoritesRepository.stored.contains(target.id), true)
        XCTAssertGreaterThan(favoritesRepository.saveCallCount, 0)
    }

    func testUpdateNotePersistsContent() async {
        let spot = TourSpot.mockSpots[0]
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let contentRepository = UserSpotContentRepositoryStub(initial: [spot.id: UserSpotContent(note: \"旧メモ\", checklist: [])])
        let intent = TourGuideIntent(
            repository: repository,
            themeRepository: ThemeSettingsRepositoryStub(),
            favoritesRepository: FavoritesRepositoryStub(),
            userContentRepository: contentRepository
        )
        await intent.handle(.loadSpots)

        await intent.handle(.updateNote(spotID: spot.id, text: \"最新メモ\"))

        XCTAssertEqual(intent.state.userContents[spot.id]?.note, \"最新メモ\")
        XCTAssertEqual(contentRepository.storage[spot.id]?.note, \"最新メモ\")
    }

    func testToggleChecklistItemUpdatesState() async {
        var content = UserSpotContent(note: \"\", checklist: [SpotChecklistItem(title: \"撮影スポット\")])
        let itemID = content.checklist[0].id
        let spot = TourSpot.mockSpots[0]
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let contentRepository = UserSpotContentRepositoryStub(initial: [spot.id: content])
        let intent = TourGuideIntent(
            repository: repository,
            themeRepository: ThemeSettingsRepositoryStub(),
            favoritesRepository: FavoritesRepositoryStub(),
            userContentRepository: contentRepository
        )
        await intent.handle(.loadSpots)

        await intent.handle(.toggleChecklistItem(spotID: spot.id, itemID: itemID))

        XCTAssertEqual(intent.state.userContents[spot.id]?.checklist[0].isCompleted, true)
    }
}
