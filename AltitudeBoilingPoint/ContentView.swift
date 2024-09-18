//
//  ContentView.swift
//  Boiling Point at Altitude
//
//  COMPLETE WORKING FILE - Paste into Xcode
//

import SwiftUI
import CoreMotion
import CoreLocation

struct ContentView: View {
    @State private var altitudeManager = AltitudeManager()
    
    // Unit preferences stored in UserDefaults via @AppStorage
    @AppStorage("useCelsius") private var useCelsius: Bool = false
    @AppStorage("useMeters") private var useMeters: Bool = false
    @AppStorage("useKPa") private var useKPa: Bool = false
    @AppStorage("accentColor") private var accentColorName: String = "jade"
    
    // Settings sheet state
    @State private var showingSettings: Bool = false
    
    // Computed accent color
    private var accentColor: Color {
        switch accentColorName {
        case "jade": return Color(red: 0.3, green: 0.7, blue: 0.5)
        case "blue": return Color(red: 0.3, green: 0.5, blue: 0.8)
        case "orange": return Color(red: 0.9, green: 0.5, blue: 0.3)
        case "purple": return Color(red: 0.6, green: 0.4, blue: 0.8)
        case "rose": return Color(red: 0.9, green: 0.4, blue: 0.6)
        default: return Color(red: 0.3, green: 0.7, blue: 0.5)
        }
    }
    
    var body: some View {
        ZStack {
            // Jade green double radial gradient background
            JadeGradientBackground(accentColor: accentColor)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Settings gear icon at absolute top-right
                HStack {
                    Spacer()
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gear")
                            .font(.system(size: 24))
                            .foregroundColor(accentColor)
                    }
                    .padding(.top, 8)
                    .padding(.trailing, 16)
                }
                
                // Temperature toggle centered below
                HStack {
                    Spacer()
                    temperatureToggle
                    Spacer()
                }
                .padding(.top, 24)
                
                Spacer()
                
                // Main boiling point display
                mainDisplay
                
                Spacer()
                
                // Bottom info bar
                bottomInfoBar
                    .padding(.bottom, 40)
                    .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onAppear {
            altitudeManager.startMonitoring()
        }
        .onDisappear {
            altitudeManager.stopMonitoring()
        }
    }
    
    // MARK: - Temperature Toggle
    private var temperatureToggle: some View {
        HStack(spacing: 12) {
            TemperatureButton(
                symbol: "°F",
                isSelected: !useCelsius,
                action: { useCelsius = false }
            )
            TemperatureButton(
                symbol: "°C",
                isSelected: useCelsius,
                action: { useCelsius = true }
            )
        }
    }
    
    // MARK: - Main Display
    private var mainDisplay: some View {
        VStack(spacing: 16) {
            if let error = altitudeManager.errorMessage {
                errorView(message: error)
            } else if altitudeManager.isUpdating, let boilingPoint = altitudeManager.boilingPointCelsius {
                boilingPointView(celsius: boilingPoint)
            } else if altitudeManager.isUpdating {
                loadingView
            } else {
                inactiveView
            }
        }
    }
    
    private func boilingPointView(celsius: Double) -> some View {
        VStack(spacing: 8) {
            Text(formattedTemperature(celsius: celsius))
                .font(.system(size: 120, weight: .medium, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text("Boiling Point")
                .font(.system(size: 24, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text(message)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Measuring altitude...")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    private var inactiveView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
            
            Text("Sensors inactive")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Bottom Info Bar
    private var bottomInfoBar: some View {
        HStack(spacing: 32) {
            if let altitude = altitudeManager.currentAltitudeMeters {
                Button(action: { useMeters.toggle() }) {
                    InfoPill(
                        icon: "mountain.2.fill",
                        value: formattedAltitude(meters: altitude),
                        label: "Altitude"
                    )
                }
                .buttonStyle(.plain)
            }
            
            if let pressure = altitudeManager.currentPressureKPa {
                Button(action: { useKPa.toggle() }) {
                    InfoPill(
                        icon: "gauge.with.dots.needle.bottom.50percent",
                        value: formattedPressure(kPa: pressure),
                        label: "Pressure"
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func formattedTemperature(celsius: Double) -> String {
        if useCelsius {
            return String(format: "%.1f°", celsius)
        } else {
            let fahrenheit = celsius * 9.0 / 5.0 + 32.0
            return String(format: "%.1f°", fahrenheit)
        }
    }
    
    private func formattedAltitude(meters: Double) -> String {
        if useMeters {
            return String(format: "%.0f m", meters)
        } else {
            let feet = meters * 3.28084
            return String(format: "%.0f ft", feet)
        }
    }
    
    private func formattedPressure(kPa: Double) -> String {
        if useKPa {
            return String(format: "%.1f kPa", kPa)
        } else {
            // Convert kPa to inHg (inches of mercury)
            // 1 kPa = 0.2953 inHg
            let inHg = kPa * 0.2953
            return String(format: "%.2f inHg", inHg)
        }
    }
}

// MARK: - Temperature Button Component
struct TemperatureButton: View {
    let symbol: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(symbol)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .white.opacity(0.4))
                .frame(width: 70, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.white.opacity(0.2) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    Color.white.opacity(isSelected ? 0.4 : 0.2),
                                    lineWidth: 2
                                )
                        )
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Info Pill Component
struct InfoPill: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Jade Green Gradient Background
struct JadeGradientBackground: View {
    let accentColor: Color
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Base jade green color
            (colorScheme == .dark
                ? Color(red: 0.05, green: 0.15, blue: 0.12)
                : Color(red: 0.08, green: 0.18, blue: 0.15))
                .ignoresSafeArea()
            
            // First radial gradient (top-left) - lighter jade
            RadialGradient(
                colors: [
                    accentColor.opacity(colorScheme == .dark ? 0.35 : 0.25),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 50,
                endRadius: 500
            )
            
            // Second radial gradient (bottom-right) - deeper jade/teal
            RadialGradient(
                colors: [
                    Color(red: 0.2, green: 0.5, blue: 0.4)
                        .opacity(colorScheme == .dark ? 0.3 : 0.2),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 50,
                endRadius: 550
            )
            
            // Subtle noise/grain overlay
            Rectangle()
                .fill(Color.white.opacity(0.02))
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
