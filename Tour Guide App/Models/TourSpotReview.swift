import Foundation

struct TourSpotReview: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let author: String
    let title: String
    let body: String
    let rating: Double
    let visitDate: Date

    static func samples(for spotName: String) -> [TourSpotReview] {
        [
            TourSpotReview(
                id: UUID(),
                author: "Ayumi",
                title: "\(spotName)で心が洗われた",
                body: "早朝に訪れると人も少なくて、ゆっくり写真が撮れました。案内板も多言語対応で助かります。",
                rating: 4.8,
                visitDate: Date(timeIntervalSince1970: 1_706_176_800)
            ),
            TourSpotReview(
                id: UUID(),
                author: "Leo",
                title: "ライトアップが最高",
                body: "夜のライトアップイベントが幻想的。混雑するので事前予約がおすすめです。",
                rating: 4.6,
                visitDate: Date(timeIntervalSince1970: 1_704_672_000)
            )
        ]
    }
}
