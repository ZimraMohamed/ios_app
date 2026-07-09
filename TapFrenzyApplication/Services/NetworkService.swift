import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    private init() {}
    
   
    func fetchQuizQuestions() async throws -> [Question] {
        let urlString = "https://opentdb.com/api.php?amount=10&type=multiple"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
       
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        
        let decodedResponse = try JSONDecoder().decode(QuizResponse.self, from: data)
        return decodedResponse.results
    }
}
