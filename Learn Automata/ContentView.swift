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
    
    let gradients = [
        LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(gradient: Gradient(colors: [.purple, .pink]), startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(gradient: Gradient(colors: [.green, .mint]), startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(gradient: Gradient(colors: [.indigo, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
    ]
    
    @State private var appear = false
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Progress
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Overall Progress")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 12)
                                    .foregroundColor(Color.primary.opacity(0.1))
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: geometry.size.width * CGFloat(progressManager.totalProgress()), height: 12)
                                    .foregroundColor(.blue)
                                    .animation(.spring(), value: progressManager.totalProgress())
                            }
                        }
                        .frame(height: 12)
                        
                        Text("\(Int(progressManager.totalProgress() * 100))% Complete")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .background(Color.primary.colorInvert())
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                    
                    // Unit Cards
                    ForEach(0..<units.count, id: \.self) { index in
                        let unit = units[index]
                        NavigationLink(destination: getDestination(for: unit)) {
                            HStack(spacing: 16) {
                                Image(systemName: unit.icon)
                                    .foregroundColor(.white)
                                    .font(.system(size: 26, weight: .semibold))
                                    .frame(width: 60, height: 60)
                                    .background(gradients[index % gradients.count])
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(unit.title)
                                            .font(.system(.title3, design: .rounded))
                                            .bold()
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("\(Int(progressManager.unitProgress(for: unit.title) * 100))%")
                                            .font(.caption)
                                            .bold()
                                            .foregroundColor(.blue)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    
                                    Text(unit.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .padding()
                            .background(Color.primary.colorInvert())
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.1), value: appear)
                    }
                }
                .padding()
            }
            .navigationTitle("Automata Theory")
            .background(Color.primary.opacity(0.05).edgesIgnoringSafeArea(.all))
            .onAppear {
                appear = true
            }
        }
    }
    
    @ViewBuilder
    func getDestination(for unit: Unit) -> some View {
        UnitDetailView(unit: unit)
    }
}
