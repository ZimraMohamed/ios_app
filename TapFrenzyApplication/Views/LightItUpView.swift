import SwiftUI
import Combine

struct LightItUpView: View {

    @AppStorage("lightItUpHighScore") private var highScore = 0

    @State private var score = 0
    @State private var timeElapsed = 0
    @State private var lives = 3
    @State private var isGameOver = false
    @State private var isNewHighScore = false
    @State private var hasRecordedThisRound = false
    @State private var showHistory = false

    @State private var cards: [Card] = []
    @State private var currentLevel: Level = .L1
    @State private var showLevelFlash = false

    private let roundTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()


    @State private var gameTimer: AnyCancellable?

    var body: some View {
        ZStack {
            AmbientBackground(colors: [
                Color(red: 0.06, green: 0.07, blue: 0.14),
                Color(red: 0.05, green: 0.10, blue: 0.22)
            ])

            if !isGameOver {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Level: \(currentLevel.rawValue)")
                                .font(.title2).bold()
                                .foregroundColor(currentLevel.glowColor)
                            Text("Time: \(60 - timeElapsed)s")
                                .font(.subheadline).foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Score: \(score)").font(.title2).bold()
                                .foregroundColor(.white)
                            Text("High Score: \(highScore)").font(.subheadline).foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal)

                    // Round progress bar gives a persistent, glanceable read on
                    // how far into the 60s round the player is.
                    ProgressView(value: Double(timeElapsed), total: 60)
                        .tint(currentLevel.glowColor)
                        .padding(.horizontal)

                    HStack {
                        ForEach(0..<3) { index in
                            Image(systemName: index < lives ? "heart.fill" : "heart")
                                .foregroundColor(.red)
                                .font(.title3)
                                .scaleEffect(index < lives ? 1.0 : 0.85)
                                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: lives)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    Spacer()


                    LazyVGrid(columns: currentLevel.columns, spacing: 15) {
                        ForEach(cards) { card in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(card.isLit ? currentLevel.glowColor : Color.white.opacity(0.08))
                                .frame(height: 110)
                                .shadow(color: card.isLit ? currentLevel.glowColor : .clear, radius: card.isLit ? 12 : 0)
                                .scaleEffect(card.isLit ? 1.05 : 1.0)
                                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: card.isLit)
                                .onTapGesture {
                                    handleTap(on: card)
                                }
                        }
                    }
                    .padding(25)

                    Spacer()
                }
            } else {
                GameOverCard(
                    title: "Game Over",
                    score: score,
                    highScore: highScore,
                    isNewHighScore: isNewHighScore,
                    accentColor: .blue,
                    onPlayAgain: { resetGame() },
                    onViewHistory: { showHistory = true }
                )
            }


            if showLevelFlash {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                Text("LEVEL UP\n\(currentLevel.rawValue)")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(currentLevel.glowColor)
                    .multilineTextAlignment(.center)
                    .transition(.scale)
            }
        }
        .navigationTitle("Light It Up")
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
            GameHistoryView(gameID: .lightItUp, gameTitle: "Light It Up", accentColor: .blue)
        }
        .onAppear {
            resetGame()
        }
        .onDisappear {
            stopTimers()
        }

        .onReceive(roundTimer) { _ in
            guard !isGameOver else { return }

            timeElapsed += 1


            if timeElapsed >= 60 {
                endGame()
                return
            }


            let computedLevel = Level.getLevel(for: timeElapsed)
            if computedLevel != currentLevel {
                Haptics.medium()
                withAnimation {
                    currentLevel = computedLevel
                    showLevelFlash = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation { showLevelFlash = false }
                }
                setupGrid()
                startGameTickTimer()
            }
        }
    }


    private func setupGrid() {
        cards = (0..<currentLevel.cardCount).map { Card(id: $0) }
    }


    private func startGameTickTimer() {
        gameTimer?.cancel()

        gameTimer = Timer.publish(every: currentLevel.litWindow, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                guard !self.isGameOver && !self.cards.isEmpty else { return }


                for i in 0..<self.cards.count {
                    self.cards[i].isLit = false
                }


                let countToLight = (self.currentLevel == .L4) ? 2 : 1
                var litIndices = Set<Int>()

                while litIndices.count < min(countToLight, self.cards.count) {
                    let randomIdx = Int.random(in: 0..<self.cards.count)
                    litIndices.insert(randomIdx)
                }

                withAnimation(.easeInOut(duration: 0.15)) {
                    for index in litIndices {
                        self.cards[index].isLit = true
                    }
                }
            }
    }


    private func handleTap(on card: Card) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[index].isLit {

            score += 1
            Haptics.light()
            withAnimation(.easeOut(duration: 0.1)) {
                cards[index].isLit = false
            }
        } else {

            lives -= 1
            Haptics.error()
            if lives <= 0 {
                endGame()
            }
        }
    }

    private func resetGame() {
        score = 0
        timeElapsed = 0
        lives = 3
        isGameOver = false
        isNewHighScore = false
        hasRecordedThisRound = false
        currentLevel = .L1
        setupGrid()
        startGameTickTimer()
    }

    private func endGame() {
        isGameOver = true
        stopTimers()
        isNewHighScore = score > highScore
        if isNewHighScore {
            highScore = score
            Haptics.success()
        }
        if !hasRecordedThisRound {
            HistoryStore.shared.addRecord(score: score, detail: "Reached Level \(currentLevel.rawValue)", for: .lightItUp)
            hasRecordedThisRound = true
        }
    }

    private func stopTimers() {
        gameTimer?.cancel()
    }
}
