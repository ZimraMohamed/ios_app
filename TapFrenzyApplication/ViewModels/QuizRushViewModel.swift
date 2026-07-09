import SwiftUI
import Combine

enum QuizState {
    case loading
    case loaded
    case failed
    case finished
}

@MainActor
class QuizRushViewModel: ObservableObject {
    @Published var appState: QuizState = .loading
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var bestStreak: Int = 0
    @Published var isNewHighScore: Bool = false

 
    @Published var feedbackColor: Color = .clear

    private let highScoreKey = "quizRushHighScore"
    private var hasRecordedThisRound = false

    var highScore: Int {
        UserDefaults.standard.integer(forKey: highScoreKey)
    }

  
    private var scoreMultiplier: Int {
        if streak >= 5 { return 3 }
        if streak >= 3 { return 2 }
        return 1
    }

   
    func loadQuizData() async {
        appState = .loading
        do {
            let items = try await NetworkService.shared.fetchQuizQuestions()
            self.questions = items
            self.currentIndex = 0
            self.score = 0
            self.streak = 0
            self.bestStreak = 0
            self.isNewHighScore = false
            self.hasRecordedThisRound = false
            self.appState = .loaded
        } catch {
            self.appState = .failed
        }
    }

   
    func evaluateUserAnswer(_ selectedOption: String) {
        let currentQuestion = questions[currentIndex]

        if selectedOption == currentQuestion.correctAnswer {
            
            streak += 1
            bestStreak = max(bestStreak, streak)
            score += (10 * scoreMultiplier)
            Haptics.light()

            withAnimation { feedbackColor = .green.opacity(0.4) } 
        } else {
            
            streak = 0
            score = max(0, score - 5)
            Haptics.error()

            withAnimation { feedbackColor = .red.opacity(0.4) }
        }

      
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation {
                self.feedbackColor = .clear
                if self.currentIndex + 1 < self.questions.count {
                    self.currentIndex += 1
                } else {
                    self.appState = .finished
                
                    self.finishQuiz()
                }
            }
        }
    }


    private func finishQuiz() {
        isNewHighScore = score > highScore
        if isNewHighScore {
            UserDefaults.standard.set(score, forKey: highScoreKey)
            Haptics.success()
        }
        if !hasRecordedThisRound {
            HistoryStore.shared.addRecord(score: score, detail: "Best streak: \(bestStreak)", for: .quizRush)
            hasRecordedThisRound = true
        }
    }
}
