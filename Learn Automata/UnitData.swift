import Foundation

struct UnitContent {
    let theory: [Topic]
    let examples: [Topic]
    let quizzes: [QuizQuestion]
}

func getUnitContent(for title: String) -> UnitContent {
    if title.contains("Unit 1") { return unit1Content }
    if title.contains("Unit 2") { return unit2Content }
    if title.contains("Unit 3") { return unit3Content }
    if title.contains("Unit 4") { return unit4Content }
    if title.contains("Unit 5") { return unit5Content }
    return UnitContent(theory: [], examples: [], quizzes: [])
}
