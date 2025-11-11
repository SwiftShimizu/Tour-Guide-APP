import XCTest
@testable import Tour_Guide_App

final class UserSpotContentRepositoryTests: XCTestCase {
    func testSaveAndLoadContent() {
        let suite = "UserSpotContentRepositoryTests"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let repository = UserDefaultsUserSpotContentRepository(defaults: defaults)
        let spotID = UUID()
        let content = UserSpotContent(note: "新規メモ", checklist: [SpotChecklistItem(title: "写真撮影", isCompleted: false)])

        repository.save(content: content, for: spotID)
        let loaded = repository.loadAll()[spotID]

        XCTAssertEqual(loaded?.note, content.note)
        XCTAssertEqual(loaded?.checklist.count, 1)
    }
}
