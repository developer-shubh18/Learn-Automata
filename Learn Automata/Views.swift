import SwiftUI

// MARK: - Unit Detail View
struct UnitDetailView: View {
    let unit: Unit
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        let content = getUnitContent(for: unit.title)
        
        List {
            Section(header: Text("Learning Path").font(.headline)) {
                NavigationLink(destination: GenericTheoryView(unit: unit, theoryTopics: content.theory)) {
                    Label("Theory Notes", systemImage: "book.fill")
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                }
                NavigationLink(destination: GenericExamplesView(unit: unit, exampleTopics: content.examples)) {
                    Label("Examples", systemImage: "lightbulb.fill")
                        .foregroundColor(.purple)
                        .padding(.vertical, 4)
                }
                NavigationLink(destination: QuizView(unit: unit, questions: content.quizzes)) {
                    HStack {
                        Label("Quiz", systemImage: "checklist")
                            .foregroundColor(.green)
                            .padding(.vertical, 4)
                        Spacer()
                        if progressManager.isCompleted("\(unit.title)_quiz") {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                NavigationLink(destination: SimulatorView(unit: unit)) {
                    HStack {
                        Label("Interactive Simulator", systemImage: "bolt.fill")
                            .foregroundColor(.orange)
                            .padding(.vertical, 4)
                        Spacer()
                        if progressManager.isCompleted("\(unit.title)_simulator") {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                NavigationLink(destination: FlashcardsView(unit: unit, topics: content.theory + content.examples)) {
                    HStack {
                        Label("Flashcards Practice", systemImage: "rectangle.stack.fill")
                            .foregroundColor(.pink)
                            .padding(.vertical, 4)
                        Spacer()
                        if progressManager.isCompleted("\(unit.title)_flashcards") {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .navigationTitle(unit.title)
    }
}

// MARK: - Generic Theory View
struct GenericTheoryView: View {
    let unit: Unit
    let theoryTopics: [Topic]
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        List {
            if theoryTopics.isEmpty {
                Text("Content coming soon...")
                    .foregroundColor(.secondary)
            } else {
                ForEach(0..<theoryTopics.count, id: \.self) { index in
                    NavigationLink(destination: TopicDetailView(topics: theoryTopics, initialIndex: index, trackingPrefix: "\(unit.title)_theory")) {
                        HStack {
                            Text(theoryTopics[index].title)
                                .padding(.vertical, 4)
                            Spacer()
                            if progressManager.isCompleted("\(unit.title)_theory_\(index)") {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Theory Notes")
    }
}

// MARK: - Generic Examples View
struct GenericExamplesView: View {
    let unit: Unit
    let exampleTopics: [Topic]
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        List {
            if exampleTopics.isEmpty {
                Text("Content coming soon...")
                    .foregroundColor(.secondary)
            } else {
                ForEach(0..<exampleTopics.count, id: \.self) { index in
                    NavigationLink(destination: TopicDetailView(topics: exampleTopics, initialIndex: index, trackingPrefix: "\(unit.title)_example")) {
                        HStack {
                            Text(exampleTopics[index].title)
                                .padding(.vertical, 4)
                            Spacer()
                            if progressManager.isCompleted("\(unit.title)_example_\(index)") {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Examples")
    }
}

// MARK: - Topic Detail View
struct TopicDetailView: View {
    let topics: [Topic]
    let trackingPrefix: String
    @State var currentIndex: Int
    @EnvironmentObject var progressManager: ProgressManager
    
    init(topics: [Topic], initialIndex: Int, trackingPrefix: String) {
        self.topics = topics
        self.trackingPrefix = trackingPrefix
        self._currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(topics[currentIndex].title)
                    .font(.system(.title, design: .rounded))
                    .bold()
                    .foregroundColor(.primary)
                
                Text(topics[currentIndex].content)
                    .font(.body)
                    .lineSpacing(6)
                    .foregroundColor(.secondary)
                
                Spacer(minLength: 40)
                
                HStack(spacing: 16) {
                    if currentIndex > 0 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentIndex -= 1
                            }
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                    } else {
                        Spacer().frame(maxWidth: .infinity)
                    }
                    
                    if currentIndex < topics.count - 1 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentIndex += 1
                            }
                        }) {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    } else {
                        Spacer().frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(24)
            .background(Color.primary.colorInvert())
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            .padding()
            .id(currentIndex)
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
        .background(Color.primary.opacity(0.05).edgesIgnoringSafeArea(.all))
        .onAppear {
            progressManager.markAsCompleted("\(trackingPrefix)_\(currentIndex)")
        }
        .onChange(of: currentIndex) { oldState, newValue in
            progressManager.markAsCompleted("\(trackingPrefix)_\(newValue)")
        }
    }
}
