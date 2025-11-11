import Foundation

struct UserSpotContent: Codable, Equatable {
    var note: String
    var checklist: [SpotChecklistItem]
    var updatedAt: Date

    init(note: String = "", checklist: [SpotChecklistItem] = [], updatedAt: Date = Date()) {
        self.note = note
        self.checklist = checklist
        self.updatedAt = updatedAt
    }

    mutating func updateNote(_ newValue: String) {
        note = newValue
        updatedAt = Date()
    }

    mutating func toggleItem(id: UUID) {
        guard let index = checklist.firstIndex(where: { $0.id == id }) else { return }
        checklist[index].isCompleted.toggle()
        updatedAt = Date()
    }

    mutating func appendChecklist(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        checklist.append(SpotChecklistItem(title: trimmed))
        updatedAt = Date()
    }

    static func template(for spot: TourSpot) -> UserSpotContent {
        let baseItems = spot.highlights.isEmpty ? defaultChecklist : spot.highlights
        let checklist = baseItems.map { SpotChecklistItem(title: $0) }
        return UserSpotContent(note: "", checklist: checklist)
    }

    private static let defaultChecklist = [
        "写真スポットを確認",
        "最寄り駅をチェック",
        "営業時間をメモ"
    ]
}

struct SpotChecklistItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
