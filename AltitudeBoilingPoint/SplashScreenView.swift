//
//  SplashScreenView.swift
//  AltitudeBoilingPoint
//
//  Created by lucious lucius on 12/12/25.
//


//
//  SplashScreenView.swift
//  Boiling Point at Altitude
//
//  Animated splash screen with boiling water and mountains
//

import SwiftUI

struct SplashScreenView: View {
    @State private var wavePhase: Double = 0
    @State private var bubbles: [Bubble] = []
    @State private var opacity: Double = 1.0
    @State private var mountainScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Deep jade gradient background (ocean depths to sky)
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.1, blue: 0.08),   // Deep ocean
                    Color(red: 0.05, green: 0.15, blue: 0.12),  // Mid depth
                    Color(red: 0.1, green: 0.25, blue: 0.2)     // Surface
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            
            // Rising mountain silhouettes from the sea
            GeometryReader { geometry in
                MountainSilhouette(peaks: 5)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.35, blue: 0.25).opacity(0.6),
                                Color(red: 0.1, green: 0.25, blue: 0.18).opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: geometry.size.height * 0.4)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.75)
                    .scaleEffect(mountainScale)
                    .animation(.easeOut(duration: 1.5), value: mountainScale)
            }
            
            // Boiling water waves (multiple layers)
            ZStack {
                WaveShape(phase: wavePhase, amplitude: 15, frequency: 1.5)
                    .fill(Color(red: 0.2, green: 0.5, blue: 0.4).opacity(0.3))
                    .frame(height: 300)
                    .offset(y: 100)
                
                WaveShape(phase: wavePhase + 90, amplitude: 12, frequency: 1.2)
                    .fill(Color(red: 0.25, green: 0.55, blue: 0.45).opacity(0.4))
                    .frame(height: 300)
                    .offset(y: 90)
                
                WaveShape(phase: wavePhase + 180, amplitude: 18, frequency: 1.8)
                    .fill(Color(red: 0.3, green: 0.7, blue: 0.5).opacity(0.5))
                    .frame(height: 300)
                    .offset(y: 80)
            }
            
            // Floating bubbles
            ForEach(bubbles) { bubble in
                Circle()
                    .fill(Color.white.opacity(bubble.opacity))
                    .frame(width: bubble.size, height: bubble.size)
                    .position(x: bubble.x, y: bubble.y)
                    .blur(radius: 1)
            }
            
            // App title
            VStack(spacing: 16) {
                Image(systemName: "mountain.2.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.4, green: 0.8, blue: 0.6),
                                Color(red: 0.3, green: 0.7, blue: 0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Text("Boiling Point")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Text("at Altitude")
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .opacity(titleOpacity)
            .animation(.easeIn(duration: 1.0).delay(0.3), value: titleOpacity)
        }
        .opacity(opacity)
        .onAppear {
            startAnimations()
            
            // Dismiss splash after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
    
    private func startAnimations() {
        // Animate waves continuously
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            wavePhase = 360
        }
        
        // Scale up mountain
        withAnimation(.easeOut(duration: 1.5)) {
            mountainScale = 1.0
        }
        
        // Fade in title
        withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
            titleOpacity = 1.0
        }
        
        // Generate bubbles
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            if bubbles.count > 30 {
                bubbles.removeFirst()
            }
            
            let screenWidth = UIScreen.main.bounds.width
            let bubble = Bubble(
                x: CGFloat.random(in: 50...(screenWidth - 50)),
                y: UIScreen.main.bounds.height + 50
            )
            bubbles.append(bubble)
            
            withAnimation(.linear(duration: Double.random(in: 2.0...4.0))) {
                if let index = bubbles.firstIndex(where: { $0.id == bubble.id }) {
                    bubbles[index].y = -50
                    bubbles[index].opacity = 0
                }
            }
        }
    }
}

// MARK: - Wave Shape
struct WaveShape: Shape {
    var phase: Double
    var amplitude: Double
    var frequency: Double
    
    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin((relativeX * frequency * 2 * .pi) + (phase * .pi / 180))
            let y = midHeight + (sine * amplitude)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Mountain Silhouette
struct MountainSilhouette: Shape {
    let peaks: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let peakWidth = width / CGFloat(peaks)
        
        path.move(to: CGPoint(x: 0, y: height))
        
        for i in 0..<peaks {
            let baseX = CGFloat(i) * peakWidth
            let peakHeight = CGFloat.random(in: 0.6...1.0) * height
            let peakOffset = CGFloat.random(in: 0.3...0.7) * peakWidth
            
            // Left slope
            path.addLine(to: CGPoint(x: baseX + peakOffset, y: height - peakHeight))
            // Right slope
            path.addLine(to: CGPoint(x: baseX + peakWidth, y: height - (peakHeight * 0.5)))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Bubble Model
struct Bubble: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat = CGFloat.random(in: 4...12)
    var opacity: Double = Double.random(in: 0.3...0.7)
}

// MARK: - Preview
#Preview {
    SplashScreenView {
        print("Splash complete")
    }
}