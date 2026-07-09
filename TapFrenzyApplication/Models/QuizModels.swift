import Foundation


struct QuizResponse: Codable {
    let results: [Question]
}


struct Question: Codable, Identifiable {
    var id: UUID { UUID() }
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    
   
    enum CodingKeys: String, CodingKey {
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
    
    
    var allAnswersShuffled: [String] {
        var answers = incorrectAnswers
        answers.append(correctAnswer)
        return answers.shuffled() 
    }
}

