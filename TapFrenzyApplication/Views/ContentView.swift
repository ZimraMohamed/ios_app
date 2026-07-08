import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Tap Frenzy")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .padding(.top, 40)
                
                Text("Select a game mode to start playing")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                
                NavigationLink(destination: TapFrenzyView()) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .font(.title)
                        Text("Play Tap Frenzy")
                            .font(.title2).bold()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
                    .background(Color.green)
                    .cornerRadius(16)
                    .shadow(radius: 4)
                }
                
                
                NavigationLink(destination: LightItUpView()) {
                    HStack {
                        Image(systemName: "square.grid.3x3.topleft.filled")
                            .font(.title)
                        Text("Play Light It Up")
                            .font(.title2).bold()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 90)
                    .background(Color.blue)
                    .cornerRadius(16)
                    .shadow(radius: 4)
                }
                
                Spacer()
                Spacer()
            }
            .padding(30)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ContentView()
}
