import SwiftUI

// MARK: - Press-scale button style used across the hub for a tactile, springy feel.

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.55), value: configuration.isPressed)
    }
}

// MARK: - Animated ambient gradient background used behind the hub & game screens.

struct AmbientBackground: View {
    var colors: [Color]

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Hub game card content (icon + title + subtitle + live best-score badge)
//
// This is a pure view (no Button/gesture of its own) so it can be dropped
// straight into a NavigationLink's label. That keeps the whole card tappable
// via standard navigation while still getting the bouncy press style and
// haptic tick from the modifiers applied at the call site.

struct GameCardContent: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let gradient: [Color]
    let bestScore: Int

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.22))
                    .frame(width: 56, height: 56)
                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.85))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("BEST")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white.opacity(0.7))
                Text("\(bestScore)")
                    .font(.headline.weight(.heavy))
                    .foregroundColor(.white)
            }

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: (gradient.first ?? .black).opacity(0.35), radius: 14, x: 0, y: 8)
    }
}

// MARK: - Small stat pill, e.g. used in headers for score / lives / time

struct StatPill: View {
    let label: String
    let value: String
    var tint: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundColor(tint)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Reusable "Game Over" summary card

struct GameOverCard: View {
    let title: String
    let score: Int
    let highScore: Int
    let isNewHighScore: Bool
    let accentColor: Color
    let onPlayAgain: () -> Void
    let onViewHistory: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: isNewHighScore ? "crown.fill" : "flag.checkered")
                .font(.system(size: 54))
                .foregroundStyle(isNewHighScore ? .yellow : accentColor)
                .symbolEffect(.bounce, value: isNewHighScore)

            Text(title)
                .font(.largeTitle.weight(.black))

            if isNewHighScore {
                Text("NEW HIGH SCORE!")
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.yellow.opacity(0.25)))
                    .foregroundColor(.orange)
            }

            VStack(spacing: 6) {
                Text("\(score)")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(accentColor)
                Text("Final Score")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text("High Score: \(highScore)")
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                Button(action: {
                    Haptics.medium()
                    onPlayAgain()
                }) {
                    Text("Play Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(BouncyButtonStyle())

                Button(action: {
                    Haptics.selection()
                    onViewHistory()
                }) {
                    Label("View Play History", systemImage: "clock.arrow.circlepath")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(accentColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(accentColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(.horizontal, 20)
        }
        .padding(30)
    }
}
