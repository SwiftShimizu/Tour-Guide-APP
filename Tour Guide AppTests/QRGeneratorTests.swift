import XCTest
@testable import Tour_Guide_App

final class QRGeneratorTests: XCTestCase {
    func testGeneratesImageFromString() {
        let generator = QRGenerator()
        let image = generator.makeImage(from: "https://example.com")
        XCTAssertNotNil(image)
    }
}
