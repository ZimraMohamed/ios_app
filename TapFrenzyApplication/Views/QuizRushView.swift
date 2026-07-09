import SwiftUI

struct QuizRushView: View {
    // Instantiate presentation source dependency tracker
    @StateObject private var viewModel = QuizRushViewModel()
    @State private var showHistory = false

    var body: some View {
        ZStack {
            AmbientBackground(colors: [
                Color(red: 0.10, green: 0.06, blue: 0.16),
                Color(red: 0.18, green: 0.05, blue: 0.24)
            ])

            viewModel.feedbackColor
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut, value: viewModel.feedbackColor)

            // Render interface dynamically depending on screen state enums[cite: 2]
            switch viewModel.appState {
            case .loading: //[cite: 2]
                VStack(spacing: 15) {
                    ProgressView() // Standard system spinning loading asset[cite: 2]
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Fetching Live Trivia Questions...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.75))
                }

            case .failed: //[cite: 2]
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    Text("Connection Failure")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    Button("Retry Load") { // Error Retry Action[cite: 2]
                        Haptics.medium()
                        Task { await viewModel.loadQuizData() }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .buttonStyle(BouncyButtonStyle())
                }

            case .loaded: //[cite: 2]
                let currentQuestion = viewModel.questions[viewModel.currentIndex]

                VStack(spacing: 20) {
                    // Header Stats Block[cite: 2]
                    HStack(spacing: 12) {
                        StatPill(label: "Question", value: "\(viewModel.currentIndex + 1)/\(viewModel.questions.count)", tint: .purple)
                        StatPill(label: "Score", value: "\(viewModel.score)", tint: .white)
                        if viewModel.streak >= 3 {
                            StatPill(label: "🔥 Streak", value: "\(viewModel.streak)", tint: .orange)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)

                    ProgressView(value: Double(viewModel.currentIndex), total: Double(viewModel.questions.count))
                        .tint(.purple)
                        .padding(.horizontal)

                    Spacer()

                    // Question text frame[cite: 2]
                    Text(cleanHTMLString(currentQuestion.question)) // Cleans string data format output
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                        .id(viewModel.currentIndex)
                        .animation(.easeInOut(duration: 0.25), value: viewModel.currentIndex)

                    Spacer()

                    // Render 4 answer blocks[cite: 2]
                    VStack(spacing: 14) {
                        ForEach(currentQuestion.allAnswersShuffled, id: \.self) { option in
                            Button(action: {
                                viewModel.evaluateUserAnswer(option)
                            }) {
                                Text(cleanHTMLString(option))
                                    .font(.body).bold()
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 55)
                                    .background(.white.opacity(0.12))
                                    .cornerRadius(12)
                            }
                            .buttonStyle(BouncyButtonStyle())
                        }
                    }
                    .padding(.horizontal, 25)

                    Spacer()
                }

            case .finished:
                GameOverCard(
                    title: "Quiz Completed!",
                    score: viewModel.score,
                    highScore: viewModel.highScore,
                    isNewHighScore: viewModel.isNewHighScore,
                    accentColor: .purple,
                    onPlayAgain: { Task { await viewModel.loadQuizData() } },
                    onViewHistory: { showHistory = true }
                )
            }
        }
        .navigationTitle("Quiz Rush")
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
            GameHistoryView(gameID: .quizRush, gameTitle: "Quiz Rush", accentColor: .purple)
        }
        // Trigger initial data load via async task modifier lifecycle handle on initialization[cite: 2]
        .task {
            await viewModel.loadQuizData() //[cite: 2]
        }
    }

    // Helper function to decode standard HTML entity characters returned from trivia payloads
    private func cleanHTMLString(_ text: String) -> String {
        guard let data = text.data(using: .utf8) else { return text }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return text
    }
}
