import SwiftUI
import Combine

struct TapFrenzyView: View {
    @State private var score = 0
    @AppStorage("tapFrenzyHighScore") private var highScore = 0
    @State private var timeRemaining = 10
    @State private var buttonColor: Color = .green

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            if timeRemaining > 0 {
                VStack(spacing: 30) {
                    Text("Tap Frenzy")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Score: \(score)").font(.title)
                    Text("High Score: \(highScore)").font(.title3)
                    Text("Time: \(timeRemaining)").font(.title2)

                    Spacer()

                    Button(action: {
                        if buttonColor == .green {
                            score += 2
                        } else {
                            score -= 1
                        }
                    }) {
                        Text("TAP")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(width: CGFloat(100 + timeRemaining * 10), height: CGFloat(100 + timeRemaining * 10))
                    .background(buttonColor)
                    .clipShape(Circle())

                    Spacer()

                    Text(buttonColor == .green ? "Green = +2 Points" : "Grey = -1 Point")
                        .font(.headline)
                }
                .padding()
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                        buttonColor = Bool.random() ? .green : .gray

                        if timeRemaining == 0 {
                            if score > highScore {
                                highScore = score
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 25) {
                    Text("Game Over")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Final Score").font(.title2)
                    Text("\(score)").font(.system(size: 50)).fontWeight(.bold)
                    Text("High Score: \(highScore)").font(.title3)

                    Button("Play Again") {
                        score = 0
                        timeRemaining = 10
                        buttonColor = .green
                    }
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
    }
}
