import SwiftUI

struct FlashcardsView: View {
    let unit: Unit
    let topics: [Topic]
    
    @EnvironmentObject var progressManager: ProgressManager
    
    @State private var shuffledTopics: [Topic] = []
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var dragOffset: CGSize = .zero
    @State private var cardOpacity: Double = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Progress Header
            HStack {
                Text("Card \(currentIndex + 1) of \(shuffledTopics.count)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                
                // Track visual progress dots
                HStack(spacing: 4) {
                    ForEach(0..<min(10, shuffledTopics.count), id: \.self) { index in
                        Circle()
                            .fill(index == (currentIndex % 10) ? Color.pink : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            Spacer()
            
            // The Card
            if !shuffledTopics.isEmpty {
                ZStack {
                    // Back of Card (Content)
                    FlashcardContent(
                        title: "Answer",
                        content: shuffledTopics[currentIndex].content,
                        color: Color.pink,
                        isFlipped: true,
                        icon: "doc.text.fill"
                    )
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(isFlipped ? 1 : 0) // Hide when not flipped
                    
                    // Front of Card (Question/Title)
                    FlashcardContent(
                        title: "Question/Topic",
                        content: shuffledTopics[currentIndex].title,
                        color: Color.blue,
                        isFlipped: false,
                        icon: "questionmark.circle.fill"
                    )
                    .opacity(isFlipped ? 0 : 1) // Hide when flipped
                }
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .offset(x: dragOffset.width)
                .rotationEffect(.degrees(Double(dragOffset.width / 20)))
                .opacity(cardOpacity)
                .onTapGesture {
                    #if os(iOS)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)) {
                        isFlipped.toggle()
                    }
                }
                // SWIPE GESTURE TO NEXT/PREVIOUS
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                            cardOpacity = 1.0 - Double(abs(value.translation.width) / 500)
                        }
                        .onEnded { value in
                            if value.translation.width < -100 { // Swiped Left - Next
                                goToNextCard(direction: -1)
                            } else if value.translation.width > 100 { // Swiped Right - Previous
                                goToNextCard(direction: 1)
                            } else {
                                // Snap back
                                withAnimation(.spring()) {
                                    dragOffset = .zero
                                    cardOpacity = 1.0
                                }
                            }
                        }
                )
            } else {
                Text("No flashcards available.")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Hints / Controls
            VStack(spacing: 12) {
                Text("Tap the card to reveal the answer.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 30) {
                    Button(action: { goToNextCard(direction: 1) }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.gray)
                    }
                    .disabled(currentIndex == 0)
                    .opacity(currentIndex == 0 ? 0.3 : 1)
                    
                    Button(action: { goToNextCard(direction: -1) }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.pink)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color.primary.colorInvert())
        .onAppear {
            if shuffledTopics.isEmpty {
                shuffledTopics = topics.shuffled()
            }
            progressManager.markAsCompleted("\(unit.title)_flashcards")
        }
        .navigationTitle("Flashcards")
    }
    
    private func goToNextCard(direction: Int) {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
        
        let newIndex = currentIndex - direction
        
        // Loop around or stop at edges? Let's loop.
        if newIndex >= shuffledTopics.count {
            currentIndex = 0
            shuffledTopics = topics.shuffled() // Reshuffle on loop
        } else if newIndex < 0 {
            currentIndex = 0 // Cannot go back
        } else {
            currentIndex = newIndex
        }
        
        // Reset card state instantly before sweeping in
        isFlipped = false
        dragOffset = direction == -1 ? CGSize(width: 300, height: 0) : CGSize(width: -300, height: 0)
        cardOpacity = 0.0
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            dragOffset = .zero
            cardOpacity = 1.0
        }
    }
}

struct FlashcardContent: View {
    let title: String
    let content: String
    let color: Color
    let isFlipped: Bool
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                Spacer()
            }
            .padding(.bottom, 8)
            
            if isFlipped {
                ScrollView(showsIndicators: true) {
                    Text(content)
                        .font(.body)
                        .fontWeight(.regular)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(6)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 4)
                }
            } else {
                Spacer()
                Text(content)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .foregroundColor(.black) 
                Spacer()
            }
        }
        .padding(24)
        .frame(width: 330, height: 450)
        // Hardcoded background color for contrast so text is readable
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 10)
        // Decorative Border
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(color.opacity(0.5), lineWidth: 2)
        )
    }
}
