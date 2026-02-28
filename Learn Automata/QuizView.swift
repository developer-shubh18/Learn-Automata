import SwiftUI

struct QuizView: View {
    let unit: Unit
    let questions: [QuizQuestion]
    
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var showScore = false
    @State private var selectedOption: Int? = nil
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        ZStack {
            Color.primary.opacity(0.05).edgesIgnoringSafeArea(.all)
            
            if showScore {
                scoreView
                    .transition(.scale.combined(with: .opacity))
            } else if questions.isEmpty {
                Text("Quiz coming soon...")
                    .foregroundColor(.secondary)
            } else {
                questionView
            }
        }
        .navigationTitle("Quiz")
    }
    
    private var scoreView: some View {
        VStack(spacing: 30) {
            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: 10, x: 0, y: 5)
            
            Text("Quiz Completed!")
                .font(.system(.largeTitle, design: .rounded))
                .bold()
            
            Text("Your Score")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("\(score) / \(questions.count)")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(score > (questions.count / 2) ? .green : .orange)
            
            Button(action: {
                withAnimation(.spring()) {
                    currentQuestionIndex = 0
                    score = 0
                    showScore = false
                    selectedOption = nil
                }
            }) {
                Text("Restart Quiz")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 5)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .padding(30)
        .background(Color.primary.colorInvert())
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 10)
        .padding()
    }
    
    private var questionView: some View {
        VStack(alignment: .leading, spacing: 24) {
            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(questions.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .animation(.spring(), value: currentQuestionIndex)
            
            Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(questions[currentQuestionIndex].question)
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(.primary)
                .minimumScaleFactor(0.8)
            
            VStack(spacing: 16) {
                ForEach(0..<questions[currentQuestionIndex].options.count, id: \.self) { index in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            submitAnswer(index)
                        }
                    }) {
                        HStack {
                            Text(questions[currentQuestionIndex].options[index])
                                .font(.body)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if selectedOption == index {
                                Image(systemName: index == questions[currentQuestionIndex].correctOptionIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(index == questions[currentQuestionIndex].correctOptionIndex ? .green : .red)
                            } else if selectedOption != nil && index == questions[currentQuestionIndex].correctOptionIndex {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(buttonBackgroundColor(for: index))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(buttonBorderColor(for: index), lineWidth: 2)
                        )
                        .cornerRadius(16)
                        .foregroundColor(buttonTextColor(for: index))
                    }
                    .disabled(selectedOption != nil)
                }
            }
            
            Spacer()
            
            if selectedOption != nil {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                            Text("Explanation")
                                .font(.headline)
                        }
                        .foregroundColor(.blue)
                        
                        Text(questions[currentQuestionIndex].explanation)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            nextQuestion()
                        }
                    }) {
                        Text(currentQuestionIndex < questions.count - 1 ? "Next Question" : "View Results")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .padding(24)
        .background(Color.primary.colorInvert())
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding()
        // ID allows transition to trigger for new question
        .id(currentQuestionIndex)
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
    
    private func buttonBackgroundColor(for index: Int) -> Color {
        if let selected = selectedOption {
            if index == questions[currentQuestionIndex].correctOptionIndex {
                return Color.green.opacity(0.15)
            } else if index == selected {
                return Color.red.opacity(0.15)
            }
        }
        return Color.primary.opacity(0.05)
    }
    
    private func buttonBorderColor(for index: Int) -> Color {
        if let selected = selectedOption {
            if index == questions[currentQuestionIndex].correctOptionIndex {
                return Color.green
            } else if index == selected {
                return Color.red
            }
        }
        return Color.clear
    }
    
    private func buttonTextColor(for index: Int) -> Color {
        if let selected = selectedOption {
            if index == questions[currentQuestionIndex].correctOptionIndex {
                return .green
            } else if index == selected {
                return .red
            }
        }
        return .primary
    }
    
    private func submitAnswer(_ index: Int) {
        selectedOption = index
        let isCorrect = index == questions[currentQuestionIndex].correctOptionIndex
        if isCorrect {
            score += 1
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
        } else {
            #if os(iOS)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            #endif
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedOption = nil
        } else {
            showScore = true
            if score > (questions.count / 2) {
                progressManager.markAsCompleted("\(unit.title)_quiz")
            }
        }
    }
}
