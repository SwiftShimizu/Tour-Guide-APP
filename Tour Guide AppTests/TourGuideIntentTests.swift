import XCTest
@testable import Tour_Guide_App

@MainActor
final class TourGuideIntentTests: XCTestCase {
    func testHandleLoadSpotsUpdatesState() async {
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let themeRepository = ThemeSettingsRepositoryStub()
        let intent = TourGuideIntent(repository: repository, themeRepository: themeRepository)

        await intent.handle(.loadSpots)

        XCTAssertFalse(intent.state.spots.isEmpty)
        XCTAssertFalse(intent.state.isLoading)
        XCTAssertNil(intent.state.errorMessage)
    }

    func testHandleLoadSpotsFailureSetsError() async {
        enum StubError: Error { case failed }
        let repository = TourSpotRepositoryStub(result: .failure(StubError.failed))
        let themeRepository = ThemeSettingsRepositoryStub()
        let intent = TourGuideIntent(repository: repository, themeRepository: themeRepository)

        await intent.handle(.loadSpots)

        XCTAssertTrue(intent.state.spots.isEmpty)
        XCTAssertFalse(intent.state.isLoading)
        XCTAssertNotNil(intent.state.errorMessage)
    }

    func testToggleFavoriteViaIntentUpdatesState() async {
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let themeRepository = ThemeSettingsRepositoryStub()
        let intent = TourGuideIntent(repository: repository, themeRepository: themeRepository)
        await intent.handle(.loadSpots)
        let target = intent.state.spots[0]

        await intent.handle(.toggleFavorite(id: target.id))

        XCTAssertEqual(intent.state.spots[0].isFavorite, !target.isFavorite)
    }

    func testIntentLoadsThemeFromRepository() async {
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let themeSettings = ThemeSettings(colorStyle: .dusk, fontScale: .relaxed)
        let themeRepository = ThemeSettingsRepositoryStub(initial: themeSettings)

        let intent = TourGuideIntent(repository: repository, themeRepository: themeRepository)

        XCTAssertEqual(intent.state.themeSettings, themeSettings)
    }

    func testThemeUpdatesPersistViaIntent() async {
        let repository = TourSpotRepositoryStub(result: .success(TourSpot.mockSpots))
        let themeRepository = ThemeSettingsRepositoryStub()
        let intent = TourGuideIntent(repository: repository, themeRepository: themeRepository)

        await intent.handle(.setThemeStyle(.dark))
        await intent.handle(.setFontScale(.large))

        XCTAssertEqual(intent.state.themeSettings.colorStyle, .dark)
        XCTAssertEqual(intent.state.themeSettings.fontScale, .large)
        XCTAssertEqual(themeRepository.storedSettings.fontScale, .large)
        XCTAssertEqual(themeRepository.saveCallCount, 2)
    }
}
