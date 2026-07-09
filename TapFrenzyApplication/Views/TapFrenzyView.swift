import SwiftUI
import Combine

struct TapFrenzyView: View {
    @State private var score = 0
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    @State private var timeRemaining = 10
    @State private var buttonColor: Color = .green
    @State private var isNewHighScore = false
    @State private var hasRecordedThisRound = false
    @State private var tapPulse = false

    private let totalTime: Double = 10

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            AmbientBackground(colors: [
                Color(red: 0.05, green: 0.12, blue: 0.08),
                Color(red: 0.02, green: 0.18, blue: 0.10)
            ])

            if timeRemaining > 0 {
                VStack(spacing: 26) {
                    HStack(spacing: 12) {
                        StatPill(label: "Score", value: "\(score)", tint: .green)
                        StatPill(label: "Best", value: "\(highScore)", tint: .yellow)
                        Spacer()
                    }
                    .padding(.horizontal)

                    // Circular countdown ring gives an immediate, glanceable
                    // sense of urgency instead of relying on a plain number.
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 8)
                        Circle()
                            .trim(from: 0, to: CGFloat(timeRemaining) / totalTime)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: timeRemaining)
                        Text("\(timeRemaining)")
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 90, height: 90)

                    Spacer()

                    Button(action: { handleTap() }) {
                        Text("TAP")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: CGFloat(140 + timeRemaining * 8), height: CGFloat(140 + timeRemaining * 8))
                    .background(buttonColor.gradient)
                    .clipShape(Circle())
                    .shadow(color: buttonColor.opacity(0.6), radius: 20, y: 8)
                    .scaleEffect(tapPulse ? 0.9 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.4), value: tapPulse)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: buttonColor)

                    Spacer()

                    Text(buttonColor == .green ? "Green = +2 Points" : "Grey = -1 Point")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.bottom, 10)
                }
                .padding()
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                        buttonColor = Bool.random() ? .green : .gray

                        if timeRemaining == 0 {
                            finishRound()
                        }
                    }
                }
            } else {
                GameOverCard(
                    title: "Game Over",
                    score: score,
                    highScore: highScore,
                    isNewHighScore: isNewHighScore,
                    accentColor: .green,
                    onPlayAgain: { resetGame() },
                    onViewHistory: { showHistory = true }
                )
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Haptics.selection()
                    showHistory = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
            }
        }
        .navigationDestination(isPresented: $showHistory) {
            GameHistoryView(gameID: .tapFrenzy, gameTitle: "Tap Frenzy", accentColor: .green)
        }
    }

    @State private var showHistory = false

    private func handleTap() {
        tapPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { tapPulse = false }

        if buttonColor == .green {
            score += 2
            Haptics.light()
        } else {
            score -= 1
            Haptics.error()
        }
    }

    private func finishRound() {
        isNewHighScore = score > highScore
        if isNewHighScore {
            highScore = score
            Haptics.success()
        }
        if !hasRecordedThisRound {
            HistoryStore.shared.addRecord(score: score, detail: nil, for: .tapFrenzy)
            hasRecordedThisRound = true
        }
    }

    private func resetGame() {
        score = 0
        timeRemaining = 10
        buttonColor = .green
        isNewHighScore = false
        hasRecordedThisRound = false
    }
}
