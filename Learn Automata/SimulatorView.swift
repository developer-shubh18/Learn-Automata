import SwiftUI
import Combine

// MARK: - Main Router
struct SimulatorView: View {
    let unit: Unit
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        Group {
            if unit.title.contains("Unit 1") {
                DFASimulatorView()
            } else if unit.title.contains("Unit 2") {
                RegexSimulatorView()
            } else if unit.title.contains("Unit 3") {
                PDASimulatorView()
            } else if unit.title.contains("Unit 4") {
                TMSimulatorView()
            } else {
                ComputabilitySimulatorView()
            }
        }
        .navigationTitle("Simulator: \(unit.title.split(separator: ":").first ?? "")")
        .onAppear {
            progressManager.markAsCompleted("\(unit.title)_simulator")
        }
    }
}

// MARK: - Unit 1: DFA Simulator
struct DFAModel {
    let states: [String]
    let alphabet: [Character]
    let transitions: [String: [Character: String]]
    let startState: String
    let acceptStates: Set<String>
    let description: String
}

class DFASimulatorViewModel: ObservableObject {
    @Published var inputString: String = ""
    @Published var currentState: String = ""
    @Published var currentIndex: Int = 0
    let dfa: DFAModel
    
    init(dfa: DFAModel) {
        self.dfa = dfa
        self.currentState = dfa.startState
    }
    
    var isAccepted: Bool { dfa.acceptStates.contains(currentState) && currentIndex >= inputString.count }
    var isRejected: Bool { !dfa.acceptStates.contains(currentState) && currentIndex >= inputString.count }
    
    func reset() {
        currentState = dfa.startState
        currentIndex = 0
    }
    
    func stepForward() {
        guard currentIndex < inputString.count else { return }
        let charIndex = inputString.index(inputString.startIndex, offsetBy: currentIndex)
        let char = inputString[charIndex]
        
        if let nextState = dfa.transitions[currentState]?[char] {
            currentState = nextState
            currentIndex += 1
        } else {
            currentState = "Trap"
            currentIndex = inputString.count
        }
    }
}

struct DFASimulatorView: View {
    @StateObject private var viewModel = DFASimulatorViewModel(dfa: DFAModel(
        states: ["q0", "q1", "q2"], alphabet: ["0", "1"],
        transitions: ["q0": ["0": "q1", "1": "q0"], "q1": ["0": "q2", "1": "q0"], "q2": ["0": "q2", "1": "q0"]],
        startState: "q0", acceptStates: ["q2"], description: "DFA accepting strings ending in '00'"
    ))
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Machine:").font(.headline).foregroundColor(.secondary)
                    Text(viewModel.dfa.description).font(.title3).bold()
                }.frame(maxWidth: .infinity, alignment: .leading).padding().background(Color.blue.opacity(0.1)).cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Test String").font(.headline)
                    TextField("Enter binary string (e.g., 10100)", text: $viewModel.inputString)
                        .padding().background(Color.primary.opacity(0.05)).cornerRadius(12)
                        .onChange(of: viewModel.inputString) { _, _ in viewModel.reset() }
                }
                
                VStack(spacing: 16) {
                    Text("Tape Reader").font(.headline).frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if viewModel.inputString.isEmpty { Text("Enter a string").foregroundColor(.secondary).padding() }
                            else {
                                ForEach(0..<viewModel.inputString.count, id: \.self) { index in
                                    let char = viewModel.inputString[viewModel.inputString.index(viewModel.inputString.startIndex, offsetBy: index)]
                                    Text(String(char)).font(.title2.bold()).frame(width: 44, height: 50)
                                        .background(index < viewModel.currentIndex ? Color.gray.opacity(0.3) : (index == viewModel.currentIndex ? Color.blue : Color.clear))
                                        .foregroundColor(index == viewModel.currentIndex ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                HStack(spacing: 40) {
                    VStack {
                        Text("State").font(.subheadline).foregroundColor(.secondary)
                        Text(viewModel.currentState).font(.system(size: 40, weight: .bold, design: .monospaced)).foregroundColor(.blue)
                    }
                    VStack {
                        Text("Status").font(.subheadline).foregroundColor(.secondary)
                        if viewModel.isAccepted { Text("ACCEPTED").font(.headline.bold()).foregroundColor(.green).padding().background(Color.green.opacity(0.2)).cornerRadius(8) }
                        else if viewModel.isRejected { Text("REJECTED").font(.headline.bold()).foregroundColor(.red).padding().background(Color.red.opacity(0.2)).cornerRadius(8) }
                        else { Text("Running").font(.headline).foregroundColor(.orange).padding().background(Color.orange.opacity(0.2)).cornerRadius(8) }
                    }
                }.padding().frame(maxWidth: .infinity).background(Color.primary.opacity(0.05)).cornerRadius(16)
                
                HStack(spacing: 20) {
                    Button(action: { withAnimation { viewModel.reset() } }) {
                        Image(systemName: "arrow.counterclockwise").font(.title2).frame(width: 60, height: 60).background(Color.gray.opacity(0.2)).cornerRadius(30)
                    }
                    Button(action: { withAnimation { viewModel.stepForward() } }) {
                        HStack { Text("Step Forward").bold(); Image(systemName: "forward.fill") }
                        .frame(maxWidth: .infinity).frame(height: 60).background(viewModel.currentIndex < viewModel.inputString.count ? Color.blue : Color.gray).foregroundColor(.white).cornerRadius(30)
                    }.disabled(viewModel.currentIndex >= viewModel.inputString.count)
                }
            }.padding()
        }
    }
}

// MARK: - Unit 2: Regex Simulator
struct RegexSimulatorView: View {
    @State private var pattern: String = "^a*b+$"
    @State private var testString: String = "aaabb"
    
    var isMatch: Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(location: 0, length: testString.utf16.count)
        return regex.firstMatch(in: testString, options: [], range: range) != nil
    }
    
    var isValidPattern: Bool {
        return (try? NSRegularExpression(pattern: pattern)) != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Scenario:").font(.headline).foregroundColor(.secondary)
                    Text("Regular Expression Engine").font(.title3).bold()
                    Text("Tests if a string matches the provided POSIX syntax Regular Expression.").font(.subheadline).foregroundColor(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading).padding().background(Color.purple.opacity(0.1)).cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Regex Pattern").font(.headline)
                    TextField("Pattern (e.g. ^a*b+$)", text: $pattern)
                        .padding().background(Color.primary.opacity(0.05)).cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(isValidPattern ? Color.clear : Color.red, lineWidth: 2))
                    if !isValidPattern { Text("Invalid Regex Syntax").font(.caption).foregroundColor(.red) }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Test String").font(.headline)
                    TextField("String to test", text: $testString)
                        .padding().background(Color.primary.opacity(0.05)).cornerRadius(12)
                }
                
                VStack(spacing: 20) {
                    Text("Result").font(.headline).foregroundColor(.secondary)
                    
                    if !isValidPattern {
                        Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 60)).foregroundColor(.orange)
                        Text("ERROR").font(.title.bold()).foregroundColor(.orange)
                    } else if isMatch {
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 60)).foregroundColor(.green)
                        Text("MATCH").font(.title.bold()).foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.octagon.fill").font(.system(size: 60)).foregroundColor(.red)
                        Text("NO MATCH").font(.title.bold()).foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity).padding(.vertical, 40).background(Color.primary.opacity(0.05)).cornerRadius(16)
            }.padding()
        }
    }
}

// MARK: - Unit 3: PDA Simulator
class PDASimulatorViewModel: ObservableObject {
    @Published var inputString: String = "aabb"
    @Published var stack: [String] = ["Z0"]
    @Published var currentState: String = "q0"
    @Published var currentIndex: Int = 0
    @Published var status: String = "Ready" // Ready, Accepted, Rejected
    
    func reset() {
        stack = ["Z0"]
        currentState = "q0"
        currentIndex = 0
        status = "Ready"
    }
    
    func stepForward() {
        guard status == "Ready" || status == "Running" else { return }
        
        if currentIndex < inputString.count {
            let char = String(inputString[inputString.index(inputString.startIndex, offsetBy: currentIndex)])
            let top = stack.last ?? ""
            
            if currentState == "q0" && char == "a" && (top == "Z0" || top == "a") {
                stack.append("a")
                currentIndex += 1
                status = "Running"
            } else if currentState == "q0" && char == "b" && top == "a" {
                currentState = "q1"
                stack.removeLast()
                currentIndex += 1
                status = "Running"
            } else if currentState == "q1" && char == "b" && top == "a" {
                stack.removeLast()
                currentIndex += 1
                status = "Running"
            } else {
                status = "Rejected" // Crash
            }
        } else {
            // Epsilon transition
            if currentState == "q1" && stack.last == "Z0" {
                currentState = "q2" // Accept
                status = "Accepted"
            } else if currentState == "q0" && stack.last == "Z0" {
                currentState = "q2" // Accept empty string
                status = "Accepted"
            } else {
                status = "Rejected"
            }
        }
    }
}

struct PDASimulatorView: View {
    @StateObject private var viewModel = PDASimulatorViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Machine:").font(.headline).foregroundColor(.secondary)
                    Text("Pushdown Automaton (PDA)").font(.title3).bold()
                    Text("Language: L = { aⁿbⁿ | n ≥ 0 }. Pushes 'a's, unloads on 'b's.").font(.subheadline).foregroundColor(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading).padding().background(Color.orange.opacity(0.1)).cornerRadius(16)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Test String").font(.headline)
                    TextField("Enter a, b string", text: $viewModel.inputString)
                        .padding().background(Color.primary.opacity(0.05)).cornerRadius(12)
                        .onChange(of: viewModel.inputString) { _, _ in viewModel.reset() }
                }
                
                HStack(alignment: .top, spacing: 20) {
                    // Stack View
                    VStack {
                        Text("Stack").font(.headline)
                        VStack(spacing: 2) {
                            ForEach(viewModel.stack.reversed(), id: \.self) { item in
                                Text(item).font(.title3.bold()).frame(width: 80, height: 40)
                                    .background(item == "Z0" ? Color.gray.opacity(0.3) : Color.orange.opacity(0.5))
                                    .cornerRadius(4)
                            }
                            Rectangle().frame(width: 100, height: 4).foregroundColor(.primary)
                        }
                        .frame(height: 200, alignment: .bottom)
                        .padding().background(Color.primary.opacity(0.05)).cornerRadius(16)
                    }
                    
                    VStack(spacing: 20) {
                        VStack {
                            Text("State").font(.subheadline).foregroundColor(.secondary)
                            Text(viewModel.currentState).font(.system(size: 32, weight: .bold, design: .monospaced)).foregroundColor(.orange)
                        }.padding().frame(maxWidth: .infinity).background(Color.primary.opacity(0.05)).cornerRadius(12)
                        
                        VStack {
                            Text("Status").font(.subheadline).foregroundColor(.secondary)
                            Text(viewModel.status).font(.headline.bold())
                                .foregroundColor(viewModel.status == "Accepted" ? .green : (viewModel.status == "Rejected" ? .red : .primary))
                        }.padding().frame(maxWidth: .infinity).background(Color.primary.opacity(0.05)).cornerRadius(12)
                    }
                }
                
                HStack(spacing: 20) {
                    Button(action: { withAnimation { viewModel.reset() } }) {
                        Image(systemName: "arrow.counterclockwise").font(.title2).frame(width: 60, height: 60).background(Color.gray.opacity(0.2)).cornerRadius(30)
                    }
                    Button(action: { withAnimation { viewModel.stepForward() } }) {
                        HStack { Text("Step Forward").bold(); Image(systemName: "forward.fill") }
                        .frame(maxWidth: .infinity).frame(height: 60).background(viewModel.status != "Ready" && viewModel.status != "Running" ? Color.gray : Color.orange).foregroundColor(.white).cornerRadius(30)
                    }.disabled(viewModel.status != "Ready" && viewModel.status != "Running")
                }
            }.padding()
        }
    }
}

// MARK: - Unit 4: TM Simulator
class TMSimulatorViewModel: ObservableObject {
    @Published var tape: [String] = ["B", "1", "0", "1", "B", "B", "B"]
    @Published var head: Int = 1
    @Published var currentState: String = "q0"
    @Published var status: String = "Running"
    
    func reset() {
        tape = ["B", "1", "0", "1", "B", "B", "B"]
        head = 1
        currentState = "q0"
        status = "Running"
    }
    
    // Simple TM: Finds end of binary string, adds '#', loops back.
    func stepForward() {
        guard status == "Running" else { return }
        let symbol = tape[head]
        
        if currentState == "q0" {
            if symbol == "0" || symbol == "1" {
                head += 1
            } else if symbol == "B" {
                tape[head] = "#"
                currentState = "q1"
                head -= 1
            }
        } else if currentState == "q1" {
            if symbol == "0" || symbol == "1" {
                head -= 1
            } else if symbol == "B" {
                currentState = "q2"
                head += 1
                status = "Halted (Accept)"
            }
        } else {
            status = "Halted"
        }
    }
}

struct TMSimulatorView: View {
    @StateObject private var viewModel = TMSimulatorViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Machine:").font(.headline).foregroundColor(.secondary)
                    Text("Turing Machine").font(.title3).bold()
                    Text("Goes to the end of a binary string, writes '#', and returns to the start.").font(.subheadline).foregroundColor(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading).padding().background(Color.green.opacity(0.1)).cornerRadius(16)
                
                VStack(spacing: 16) {
                    Text("Infinite Tape").font(.headline).frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(0..<viewModel.tape.count, id: \.self) { index in
                                VStack {
                                    Image(systemName: "arrow.down").foregroundColor(index == viewModel.head ? .red : .clear)
                                    Text(viewModel.tape[index])
                                        .font(.title.bold())
                                        .frame(width: 50, height: 60)
                                        .background(Color.primary.opacity(0.05))
                                        .border(Color.gray.opacity(0.3), width: 1)
                                }
                            }
                        }
                    }
                }
                
                HStack(spacing: 40) {
                    VStack {
                        Text("State").font(.subheadline).foregroundColor(.secondary)
                        Text(viewModel.currentState).font(.system(size: 40, weight: .bold, design: .monospaced)).foregroundColor(.green)
                    }
                    VStack {
                        Text("Status").font(.subheadline).foregroundColor(.secondary)
                        Text(viewModel.status).font(.headline.bold())
                            .foregroundColor(viewModel.status.contains("Accept") ? .green : .orange)
                    }
                }.padding().frame(maxWidth: .infinity).background(Color.primary.opacity(0.05)).cornerRadius(16)
                
                HStack(spacing: 20) {
                    Button(action: { withAnimation { viewModel.reset() } }) {
                        Image(systemName: "arrow.counterclockwise").font(.title2).frame(width: 60, height: 60).background(Color.gray.opacity(0.2)).cornerRadius(30)
                    }
                    Button(action: { withAnimation { viewModel.stepForward() } }) {
                        HStack { Text("Step Forward").bold(); Image(systemName: "forward.fill") }
                        .frame(maxWidth: .infinity).frame(height: 60).background(viewModel.status == "Running" ? Color.green : Color.gray).foregroundColor(.white).cornerRadius(30)
                    }.disabled(viewModel.status != "Running")
                }
            }.padding()
        }
    }
}

// MARK: - Unit 5: Computability Simulator
struct ComputabilitySimulatorView: View {
    @State private var analysisProgress: Double = 0
    @State private var isParadox: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Concept:").font(.headline).foregroundColor(.secondary)
                    Text("The Halting Problem").font(.title3).bold()
                    Text("Can a program 'H' analyze program 'P' and determine if it halts? Let's test the paradox: P = 'if H says I halt, I loop forever'").font(.subheadline).foregroundColor(.secondary)
                }.frame(maxWidth: .infinity, alignment: .leading).padding().background(Color.red.opacity(0.1)).cornerRadius(16)
                
                VStack(spacing: 30) {
                    Image(systemName: isParadox ? "exclamationmark.triangle.fill" : "cpu.fill")
                        .font(.system(size: 80))
                        .foregroundColor(isParadox ? .red : .primary)
                        .scaleEffect(isParadox ? 1.2 : 1.0)
                        .animation(isParadox ? Animation.interpolatingSpring(stiffness: 10, damping: 1).repeatForever() : .default, value: isParadox)
                    
                    ProgressView("Analyzing Program P...", value: analysisProgress, total: 100)
                        .padding()
                    
                    if isParadox {
                        Text("PARADOX DETECTED")
                            .font(.largeTitle.bold())
                            .foregroundColor(.red)
                        Text("If H returns 'Halts', P loops forever.\nIf H returns 'Loops', P halts.\n\nConclusion: A general Halting solver is mathematically impossible.")
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding().frame(maxWidth: .infinity).background(Color.primary.opacity(0.05)).cornerRadius(16)
                
                Button(action: {
                    isParadox = false
                    analysisProgress = 0
                    
                    Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                        if analysisProgress < 100 {
                            analysisProgress += 2
                        } else {
                            timer.invalidate()
                            withAnimation { isParadox = true }
                        }
                    }
                }) {
                    Text(isParadox ? "Retry Paradox" : "Run Halting Analyzer")
                        .font(.headline)
                        .frame(maxWidth: .infinity).frame(height: 60)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
            }.padding()
        }
    }
}
