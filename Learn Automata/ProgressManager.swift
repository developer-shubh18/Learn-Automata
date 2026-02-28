import Foundation
import Combine
import SwiftUI
class ProgressManager: ObservableObject {
    @AppStorage("completedItems") private var completedItemsString: String = ""
    
    var completedItems: Set<String> {
        Set(completedItemsString.split(separator: ",").map(String.init))
    }
    
    func markAsCompleted(_ id: String) {
        var items = completedItems
        items.insert(id)
        completedItemsString = items.joined(separator: ",")
        objectWillChange.send()
    }
    
    func isCompleted(_ id: String) -> Bool {
        completedItems.contains(id)
    }
    
    func unitProgress(for title: String) -> Double {
        let content = getUnitContent(for: title)
        let totalTheory = content.theory.count
        let totalExamples = content.examples.count
        let totalItems = totalTheory + totalExamples + 3 // +1 for Quiz, +1 for Simulator, +1 for Flashcards
        
        if totalItems == 0 { return 0 }
        
        var completedCount = 0
        
        for index in 0..<totalTheory {
            if isCompleted("\(title)_theory_\(index)") {
                completedCount += 1
            }
        }
        
        for index in 0..<totalExamples {
            if isCompleted("\(title)_example_\(index)") {
                completedCount += 1
            }
        }
        
        if isCompleted("\(title)_quiz") {
            completedCount += 1
        }
        
        if isCompleted("\(title)_simulator") {
            completedCount += 1
        }
        
        if isCompleted("\(title)_flashcards") {
            completedCount += 1
        }
        
        return Double(completedCount) / Double(totalItems)
    }
    
    func totalProgress() -> Double {
        let units = [
            "Unit 1: Finite Automata",
            "Unit 2: Regular Languages",
            "Unit 3: Context-Free Grammars",
            "Unit 4: Turing Machines",
            "Unit 5: Computability"
        ]
        
        let allProgress = units.map { unitProgress(for: $0) }
        let sum = allProgress.reduce(0, +)
        return sum / Double(units.count)
    }
}
