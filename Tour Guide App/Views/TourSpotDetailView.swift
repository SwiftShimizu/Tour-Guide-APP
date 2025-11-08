import SwiftUI

struct TourSpotDetailView: View {
    let spot: TourSpot
    let onToggleFavorite: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                hero
                info
                highlights
            }
            .padding()
        }
        .navigationTitle(spot.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onToggleFavorite) {
                    Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(spot.isFavorite ? .pink : .primary)
                }
            }
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.accentColor.opacity(0.15))
                .frame(height: 220)
                .overlay {
                    Image(systemName: spot.heroImageName.isEmpty ? "globe.asia.australia.fill" : spot.heroImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                        .foregroundStyle(.black)
                }

            VStack(alignment: .leading) {
                Text(spot.locationDescription)
                    .font(.headline)
                Label("評価 \(String(format: "%.1f", spot.rating))", systemImage: "star.fill")
                    .foregroundStyle(.yellow)
            }
            .padding()
        }
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("概要")
                .font(.headline)
            Text(spot.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var highlights: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ハイライト")
                .font(.headline)
            ForEach(spot.highlights, id: \.self) { highlight in
                Label(highlight, systemImage: "checkmark.seal")
                    .foregroundStyle(.black)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TourSpotDetailView(spot: .mockSpots.first ?? .placeholder, onToggleFavorite: {})
    }
}
