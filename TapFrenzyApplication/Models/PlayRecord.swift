import Foundation


enum GameID: String, CaseIterable {
    case tapFrenzy
    case lightItUp
    case quizRush
}


struct PlayRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let date: Date
    let score: Int
   
    var detail: String?
    
    var isHighScore: Bool = false
}
