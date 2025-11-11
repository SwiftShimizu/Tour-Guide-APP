import Foundation

struct TourSpot: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    let city: String
    let country: String
    let description: String
    let heroImageName: String
    let highlights: [String]
    var isFavorite: Bool
    let rating: Double
    let tags: [String]
    var reviews: [TourSpotReview]

    var locationDescription: String {
        "\(city), \(country)"
    }

    var shortHighlights: String {
        highlights.prefix(2).joined(separator: " • ")
    }

    static let placeholder = TourSpot(
        id: UUID(),
        name: "未知のスポット",
        city: "",
        country: "",
        description: "",
        heroImageName: "globe.asia.australia.fill",
        highlights: [],
        isFavorite: false,
        rating: 0,
        tags: [],
        reviews: []
    )
}

extension TourSpot {
    static let mockSpots: [TourSpot] = [
        TourSpot(
            id: UUID(uuidString: "501A93DC-6BDB-47B1-BBE7-8D61B44A10EE")!,
            name: "伏見稲荷大社",
            city: "京都",
            country: "日本",
            description: "朱色の千本鳥居が幻想的な京都の定番スポット。早朝は静かで写真撮影にも最適です。",
            heroImageName: "torii",
            highlights: ["千本鳥居", "ご利益巡り", "早朝ハイキング"],
            isFavorite: true,
            rating: 4.9,
            tags: ["歴史", "寺社", "京都"],
            reviews: TourSpotReview.samples(for: "伏見稲荷大社")
        ),
        TourSpot(
            id: UUID(uuidString: "ACF4D3A9-4D46-4B5A-8C18-3C83D5A60644")!,
            name: "白川郷 合掌造り集落",
            city: "岐阜",
            country: "日本",
            description: "世界遺産にも登録された合掌造りの家屋が立ち並ぶ山間の集落。四季折々に違う景観を楽しめます。",
            heroImageName: "house.lodge",
            highlights: ["合掌造り", "雪景色", "郷土料理"],
            isFavorite: false,
            rating: 4.7,
            tags: ["世界遺産", "自然", "体験"],
            reviews: TourSpotReview.samples(for: "白川郷")
        ),
        TourSpot(
            id: UUID(uuidString: "FA9675AE-5947-4A49-AC14-6D07BE3A1929")!,
            name: "道後温泉本館",
            city: "松山",
            country: "日本",
            description: "日本最古といわれる公衆浴場。木造建築と温泉文化をじっくり堪能できる湯巡りスポットです。",
            heroImageName: "water.waves",
            highlights: ["温泉", "木造建築", "温泉街散策"],
            isFavorite: false,
            rating: 4.6,
            tags: ["温泉", "四国", "文化"],
            reviews: TourSpotReview.samples(for: "道後温泉")
        )
    ]
}
