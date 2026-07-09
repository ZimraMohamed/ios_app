import SwiftUI

/// A dedicated history screen for a single game mode. Reads/writes its records
/// from local storage (UserDefaults, via HistoryStore) so history persists
/// between app launches, per game.
struct GameHistoryView: View {
    let gameID: GameID
    let gameTitle: String
    let accentColor: Color

    @State private var records: [PlayRecord] = []
    @State private var showClearConfirmation = false

    private var bestScore: Int { records.map(\.score).max() ?? 0 }
    private var averageScore: Int {
        guard !records.isEmpty else { return 0 }
        return records.map(\.score).reduce(0, +) / records.count
    }

    var body: some View {
        Group {
            if records.isEmpty {
                emptyState
            } else {
                List {
                    Section {
                        HStack(spacing: 12) {
                            summaryTile(label: "Plays", value: "\(records.count)")
                            summaryTile(label: "Best", value: "\(bestScore)")
                            summaryTile(label: "Average", value: "\(averageScore)")
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 6)
                    }

                    Section("Recent Runs") {
                        ForEach(records) { record in
                            recordRow(record)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("\(gameTitle) History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    Haptics.warning()
                    showClearConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(records.isEmpty)
            }
        }
        .confirmationDialog(
            "Clear all \(gameTitle) history?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear History", role: .destructive) {
                HistoryStore.shared.clearHistory(for: gameID)
                loadRecords()
            }
            Button("Cancel", role: .cancel) {}
        }
        .onAppear(perform: loadRecords)
    }

    private func loadRecords() {
        records = HistoryStore.shared.records(for: gameID)
    }

    private func summaryTile(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.weight(.heavy))
                .foregroundColor(accentColor)
            Text(label.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func recordRow(_ record: PlayRecord) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: record.isHighScore ? "star.fill" : "gamecontroller.fill")
                    .foregroundColor(record.isHighScore ? .yellow : accentColor)
                    .font(.system(size: 16, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Score: \(record.score)")
                    .font(.headline)
                if let detail = record.detail, !detail.isEmpty {
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(record.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 46))
                .foregroundColor(.secondary)
            Text("No Runs Yet")
                .font(.title3.weight(.bold))
            Text("Play a round of \(gameTitle) and your results will show up here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
