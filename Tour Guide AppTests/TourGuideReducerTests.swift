import XCTest
@testable import Tour_Guide_App

final class TourGuideReducerTests: XCTestCase {
    func testSpotsLoadedUpdatesState() {
        var state = TourGuideState()
        let reducer = TourGuideReducer()
        let now = Date()

        let effects = reducer.reduce(state: &state, action: .spotsLoaded(TourSpot.mockSpots, now))

        XCTAssertTrue(effects.isEmpty)
        XCTAssertEqual(state.spots.count, TourSpot.mockSpots.count)
        XCTAssertEqual(state.lastUpdated, now)
        XCTAssertNil(state.errorMessage)
    }

    func testToggleFavoriteFlipsFlagAndReturnsEffect() {
        var state = TourGuideState(spots: TourSpot.mockSpots)
        let reducer = TourGuideReducer()
        let target = state.spots[0]

        let effects = reducer.reduce(state: &state, action: .toggleFavorite(target.id))

        XCTAssertEqual(state.spots[0].isFavorite, !target.isFavorite)
        XCTAssertEqual(effects, [.favoriteStatusChanged(name: target.name, isFavorite: !target.isFavorite)])
    }

    func testSelectSpotStoresSelection() {
        var state = TourGuideState(spots: TourSpot.mockSpots)
        let reducer = TourGuideReducer()
        let selected = state.spots[1]

        _ = reducer.reduce(state: &state, action: .selectSpot(selected))

        XCTAssertEqual(state.selectedSpot, selected)
    }

    func testSetThemeUpdatesState() {
        var state = TourGuideState()
        let reducer = TourGuideReducer()
        let settings = ThemeSettings(colorStyle: .dark, fontScale: .large)

        _ = reducer.reduce(state: &state, action: .setTheme(settings))

        XCTAssertEqual(state.themeSettings, settings)
    }
}
