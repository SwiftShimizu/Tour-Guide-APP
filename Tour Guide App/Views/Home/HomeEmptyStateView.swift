import SwiftUI

struct HomeEmptyStateView: View {
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("まだスポットがありません")
                .font(.headline)
            Text("[再試行]をタップしてローカルデータを読み込んでください。")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("再試行", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
