import SwiftUI

struct ContentView: View {
    // Live-updating best scores shown on each card. @AppStorage keeps these in
    // sync automatically since every game writes to these same keys.
    @AppStorage("tapFrenzyHighScore") private var tapHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightHighScore = 0
    @AppStorage("quizRushHighScore") private var quizHighScore = 0

    @State private var didAppear = false

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground(colors: [
                    Color(red: 0.08, green: 0.09, blue: 0.16),
                    Color(red: 0.15, green: 0.10, blue: 0.28)
                ])

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        header

                        VStack(spacing: 18) {
                            navCard(
                                title: "Tap Frenzy",
                                subtitle: "React fast, chase the streak",
                                systemImage: "hand.tap.fill",
                                gradient: [Color.green, Color(red: 0.05, green: 0.55, blue: 0.35)],
                                bestScore: tapHighScore,
                                destination: TapFrenzyView()
                            )

                            navCard(
                                title: "Light It Up",
                                subtitle: "Spot the glow before it fades",
                                systemImage: "square.grid.3x3.topleft.filled",
                                gradient: [Color.blue, Color(red: 0.15, green: 0.25, blue: 0.65)],
                                bestScore: lightHighScore,
                                destination: LightItUpView()
                            )

                            navCard(
                                title: "Quiz Rush",
                                subtitle: "Answer fast, build your streak",
                                systemImage: "bolt.shield.fill",
                                gradient: [Color.purple, Color(red: 0.35, green: 0.1, blue: 0.55)],
                                bestScore: quizHighScore,
                                destination: QuizRushView()
                            )
                        }
                        .padding(.horizontal, 22)

                        Spacer(minLength: 30)
                    }
                    // Extra top padding keeps content clear of the notch / Dynamic
                    // Island since the nav bar itself is hidden on this screen.
                    .padding(.top, 12)
                }
            }
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                didAppear = true
            }
        }
    }

    /// Wraps a GameCardContent view in a NavigationLink so the whole card is
    /// tappable, adds the bouncy press style, and fires a light haptic tick.
    @ViewBuilder
    private func navCard<Destination: View>(
        title: String,
        subtitle: String,
        systemImage: String,
        gradient: [Color],
        bestScore: Int,
        destination: Destination
    ) -> some View {
        NavigationLink(destination: destination) {
            GameCardContent(
                title: title,
                subtitle: subtitle,
                systemImage: systemImage,
                gradient: gradient,
                bestScore: bestScore
            )
        }
        .buttonStyle(BouncyButtonStyle())
        .simultaneousGesture(TapGesture().onEnded { Haptics.light() })
    }

    private var header: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: .purple.opacity(0.5), radius: 16, y: 6)
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(didAppear ? 1 : 0.6)
            .opacity(didAppear ? 1 : 0)

            Text("Arcade Hub")
                .font(.system(size: 40, weight: .black, design: .rounded))
                .foregroundColor(.white)

            Text("Pick a mode and beat your best score")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 8)
    }
}

#Preview {
    ContentView()
}
