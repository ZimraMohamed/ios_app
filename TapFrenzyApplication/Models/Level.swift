import SwiftUI

enum Level: String, CaseIterable {
    case L1, L2, L3, L4
    
    
    static func getLevel(for secondsElapsed: Int) -> Level {
        switch secondsElapsed {
        case 0..<15:  return .L1
        case 15..<30: return .L2
        case 30..<45: return .L3
        default:      return .L4
        }
    }
    
    var columns: [GridItem] {
        switch self {
        case .L1: return Array(repeating: GridItem(.flexible()), count: 3)
        case .L2: return Array(repeating: GridItem(.flexible()), count: 2)
        case .L3: return Array(repeating: GridItem(.flexible()), count: 2)
        case .L4: return Array(repeating: GridItem(.flexible()), count: 3)
        }
    }
    
    var cardCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }
    
    var litWindow: Double {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }
    
    var glowColor: Color {
        switch self {
        case .L1: return .blue
        case .L2: return .green
        case .L3: return .orange
        case .L4: return .red
        }
    }
}
