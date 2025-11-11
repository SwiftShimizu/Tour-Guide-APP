import SwiftUI

struct TourSpotDetailView: View {
    let spot: TourSpot
    let userContent: UserSpotContent
    let onToggleFavorite: () -> Void
    let onUpdateNote: (String) -> Void
    let onToggleChecklist: (UUID) -> Void
    let onAddChecklistItem: (String) -> Void

    @State private var noteText: String
    @State private var newChecklistTitle = ""
    @State private var isShowingQR = false
    @State private var qrImage: UIImage?

    private let qrGenerator = QRGenerator()

    init(
        spot: TourSpot,
        userContent: UserSpotContent,
        onToggleFavorite: @escaping () -> Void,
        onUpdateNote: @escaping (String) -> Void,
        onToggleChecklist: @escaping (UUID) -> Void,
        onAddChecklistItem: @escaping (String) -> Void
    ) {
        self.spot = spot
        self.userContent = userContent
        self.onToggleFavorite = onToggleFavorite
        self.onUpdateNote = onUpdateNote
        self.onToggleChecklist = onToggleChecklist
        self.onAddChecklistItem = onAddChecklistItem
        _noteText = State(initialValue: userContent.note)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero
                info
                highlights
                reviewsSection
                notesSection
                checklistSection
                shareSection
            }
            .padding()
        }
        .navigationTitle(spot.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                ShareLink(item: shareURL) {
                    Image(systemName: "square.and.arrow.up")
                }
                Button(action: onToggleFavorite) {
                    Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(spot.isFavorite ? .pink : .primary)
                }
            }
        }
        .sheet(isPresented: $isShowingQR) {
            if let image = qrImage {
                QRPreviewSheet(qrImage: image, title: spot.name)
            } else {
                ProgressView()
            }
        }
        .onChange(of: userContent.note) { _, newValue in
            if newValue != noteText {
                noteText = newValue
            }
        }
        .onChange(of: noteText) { _, newValue in
            onUpdateNote(newValue)
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.accentColor.opacity(0.15))
                .frame(height: 240)
                .overlay {
                    Image(systemName: spot.heroImageName.isEmpty ? "globe.asia.australia.fill" : spot.heroImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                        .foregroundStyle(.primary)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(spot.locationDescription)
                    .font(.headline)
                Label("評価 \(String(format: "%.1f", spot.rating))", systemImage: "star.fill")
                    .foregroundStyle(.yellow)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(spot.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(.ultraThinMaterial))
                        }
                    }
                }
            }
            .padding()
        }
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("概要")
                .font(.title3.bold())
            Text(spot.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var highlights: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ハイライト")
                .font(.title3.bold())
            ForEach(spot.highlights, id: \.self) { highlight in
                Label(highlight, systemImage: "checkmark.seal")
                    .foregroundStyle(Color.accentColor)
            }
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("レビュー")
                .font(.title3.bold())
            ForEach(spot.reviews) { review in
                ReviewCard(review: review)
            }
            if spot.reviews.isEmpty {
                Text("レビューはまだありません。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("メモ")
                    .font(.title3.bold())
                Spacer()
                if let updated = userContent.updatedAtFormatted {
                    Text("更新: \(updated)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            TextEditor(text: $noteText)
                .frame(minHeight: 120)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12).strokeBorder(Color.secondary.opacity(0.2)))
        }
    }

    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("チェックリスト")
                .font(.title3.bold())
            if userContent.checklist.isEmpty {
                Text("項目を追加して旅の TODO を管理しましょう")
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(userContent.checklist) { item in
                        Button {
                            onToggleChecklist(item.id)
                        } label: {
                            HStack {
                                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(item.isCompleted ? .green : .secondary)
                                Text(item.title)
                                    .strikethrough(item.isCompleted)
                                    .foregroundStyle(item.isCompleted ? .secondary : .primary)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                }
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
            }

            HStack {
                TextField("新しい項目", text: $newChecklistTitle)
                    .textFieldStyle(.roundedBorder)
                Button("追加") {
                    let title = newChecklistTitle
                    newChecklistTitle = ""
                    onAddChecklistItem(title)
                }
                .disabled(newChecklistTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private var shareSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("共有")
                .font(.title3.bold())
            Text("友達にスポット情報を共有したり、QRコードで素早く案内できます。")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                ShareLink(item: shareURL) {
                    Label("シェアリンクを送る", systemImage: "paperplane")
                }
                Spacer()
                Button {
                    qrImage = qrGenerator.makeImage(from: shareURL.absoluteString)
                    isShowingQR = true
                } label: {
                    Label("QR表示", systemImage: "qrcode")
                }
            }
        }
    }

    private var shareURL: URL {
        URL(string: "https://tourguide.example/spots/\(spot.id.uuidString)")!
    }
}

private struct ReviewCard: View {
    let review: TourSpotReview

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: review.visitDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(review.author)
                    .font(.headline)
                Spacer()
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(review.title)
                .font(.subheadline.bold())
            Text(review.body)
                .font(.body)
                .foregroundStyle(.secondary)
            HStack(spacing: 2) {
                ForEach(0..<5) { star in
                    Image(systemName: star < Int(review.rating.rounded(.down)) ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                }
                Text(String(format: "%.1f", review.rating))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }
}

private struct QRPreviewSheet: View {
    let qrImage: UIImage
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            Text("\(title) を共有")
                .font(.headline)
            Image(uiImage: qrImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
                .padding()
            Text("このQRコードを読み取ってスポット情報を表示できます")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }
}

private extension UserSpotContent {
    var updatedAtFormatted: String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: updatedAt)
    }
}

#Preview {
    NavigationStack {
        let spot = TourSpot.mockSpots.first ?? .placeholder
        TourSpotDetailView(
            spot: spot,
            userContent: .template(for: spot),
            onToggleFavorite: {},
            onUpdateNote: { _ in },
            onToggleChecklist: { _ in },
            onAddChecklistItem: { _ in }
        )
    }
}
