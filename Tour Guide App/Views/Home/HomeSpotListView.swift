import SwiftUI

struct HomeSpotListView: View {
    let spots: [TourSpot]
    let tintColor: Color
    let onSelect: (TourSpot) -> Void
    let onToggleFavorite: (UUID) -> Void

    var body: some View {
        List(spots) { spot in
            Button {
                onSelect(spot)
            } label: {
                TourSpotRowView(spot: spot, tintColor: tintColor)
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing) {
                Button {
                    onToggleFavorite(spot.id)
                } label: {
                    Label(
                        spot.isFavorite ? "解除" : "追加",
                        systemImage: spot.isFavorite ? "heart.slash" : "heart.fill"
                    )
                }
                .tint(spot.isFavorite ? .gray : .pink)
            }
        }
        .animation(.default, value: spots)
        .listStyle(.plain)
    }
}

struct TourSpotRowView: View {
    let spot: TourSpot
    let tintColor: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(tintColor.opacity(0.2))
                Image(systemName: spot.heroImageName.isEmpty ? "globe.asia.australia.fill" : spot.heroImageName)
                    .font(.title2)
                    .foregroundStyle(tintColor)
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(spot.name)
                    .font(.headline)
                Text(spot.locationDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(spot.shortHighlights)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(spot.isFavorite ? .pink : .secondary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 8)
    }
}
