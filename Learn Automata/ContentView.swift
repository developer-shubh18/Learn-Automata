import SwiftUI

// MARK: - Main Home Page
struct ContentView: View {
    let units = [
        Unit(title: "Unit 1: Finite Automata", description: "Overview of Deterministic Finite Automata (DFA), NFA, and conversions", icon: "circles.hexagonpath.fill"),
        Unit(title: "Unit 2: Regular Languages", description: "Regular expressions, Pumping Lemma, and closure properties", icon: "text.alignleft"),
        Unit(title: "Unit 3: Context-Free Grammars", description: "CFG derivation, Parse trees, and Pushdown Automata (PDA)", icon: "tree.fill"),
        Unit(title: "Unit 4: Turing Machines", description: "Deterministic and Non-deterministic Turing Machines", icon: "point.3.connected.trianglepath.dotted"),
        Unit(title: "Unit 5: Computability", description: "Decidability, Halting problem, and Complexity theory (P vs NP)", icon: "cpu.fill")
    ]
    
    var body: some View {
        NavigationStack {
            List(units) { unit in
                NavigationLink(destination: getDestination(for: unit)) {
                    HStack(spacing: 16) {
                        Image(systemName: unit.icon)
                            .foregroundColor(.accentColor)
                            .font(.system(size: 24))
                            .frame(width: 32)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(unit.title)
                                .font(.headline)
                            Text(unit.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Automata Theory")
        }
    }
    
    @ViewBuilder
    func getDestination(for unit: Unit) -> some View {
        UnitDetailView(unit: unit)
    }
}

struct Unit: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
}

// MARK: - Unit Detail View
struct UnitDetailView: View {
    let unit: Unit
    
    var body: some View {
        List {
            Section(header: Text("Learning Path")) {
                NavigationLink(destination: TheoryView(unit: unit)) {
                    Label("Theory Notes", systemImage: "book.fill")
                        .foregroundColor(.blue)
                }
                NavigationLink(destination: ExamplesView(unit: unit)) {
                    Label("Examples", systemImage: "lightbulb.fill")
                        .foregroundColor(.purple)
                }
                NavigationLink(destination: Text("Practice Problems Coming Soon").navigationTitle("Practice Problems")) {
                    Label("Practice Problems", systemImage: "target")
                        .foregroundColor(.red)
                }
                NavigationLink(destination: Text("Simulator Coming Soon").navigationTitle("Interactive Simulator")) {
                    Label("Interactive Simulator", systemImage: "bolt.fill")
                        .foregroundColor(.orange)
                }
                NavigationLink(destination: Text("Quiz Coming Soon").navigationTitle("Quiz")) {
                    Label("Quiz", systemImage: "checklist")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle(unit.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Theory View
struct TheoryView: View {
    let unit: Unit
    
    let unit1Topics = [
        Topic(title: "Definition of Alphabet (Σ)", content: "An alphabet is a finite, non-empty set of symbols. For example, Σ = {0, 1}."),
        Topic(title: "Strings & Languages", content: "A string is a finite sequence of symbols chosen from some alphabet. A language is a set of strings all of which are chosen from some Σ*."),
        Topic(title: "DFA (5-tuple definition)", content: "A DFA is a 5-tuple (Q, Σ, δ, q0, F) where Q is states, Σ is alphabet, δ is transition function, q0 is start state, F is accept states."),
        Topic(title: "NFA", content: "Non-Deterministic Finite Automata allows zero, one or more transitions from a state for a given symbol."),
        Topic(title: "DFA vs NFA", content: "DFA has exactly one transition for each symbol per state. NFA can have multiple transitions or none. Every NFA can be converted to an equivalent DFA."),
        Topic(title: "NFA → DFA conversion", content: "This is done using subset construction algorithm where each state of the DFA represents a subset of states of the NFA."),
        Topic(title: "ε-NFA", content: "An NFA that allows transitions without consuming any input symbol (epsilon transitions)."),
        Topic(title: "Transition Table", content: "A tabular representation of the transition function δ."),
        Topic(title: "Transition Diagram", content: "A directed graph where nodes correspond to states and edges correspond to transitions.")
    ]
    
    var body: some View {
        List {
            if unit.title.contains("Unit 1") {
                ForEach(unit1Topics) { topic in
                    NavigationLink(destination: TopicDetailView(topic: topic)) {
                        Text(topic.title)
                    }
                }
            } else {
                Text("Content coming soon...")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Theory Notes")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Examples View
struct ExamplesView: View {
    let unit: Unit
    
    let unit1Examples = [
        Topic(title: "DFA accepting strings ending with 0", content: "States: q0, q1. Transition on 0 goes to q1 (accept), 1 stays at q0..."),
        Topic(title: "DFA for even number of 1s", content: "States: even, odd. Start: even. 1 changes state, 0 stays..."),
        Topic(title: "NFA example", content: "NFA for strings ending in 11..."),
        Topic(title: "Conversion example", content: "Convert NFA for strings ending in 01 to DFA...")
    ]
    
    var body: some View {
        List {
            if unit.title.contains("Unit 1") {
                ForEach(unit1Examples) { example in
                    NavigationLink(destination: TopicDetailView(topic: example)) {
                        Text(example.title)
                    }
                }
            } else {
                Text("Content coming soon...")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Examples")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Models
struct Topic: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}

// MARK: - Topic Detail View
struct TopicDetailView: View {
    let topic: Topic
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(topic.title)
                    .font(.title)
                    .bold()
                
                Text(topic.content)
                    .font(.body)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}



#Preview {
    ContentView()
}
