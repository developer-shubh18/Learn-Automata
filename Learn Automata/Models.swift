import Foundation

struct Unit: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

struct Topic: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctOptionIndex: Int
    let explanation: String
}
