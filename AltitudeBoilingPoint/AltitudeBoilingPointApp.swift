//
//  BoilingPointAltitudeApp.swift
//  Boiling Point at Altitude
//
//  App entry point with splash screen
//

import SwiftUI

@main
struct BoilingPointAltitudeApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView {
                        showSplash = false
                    }
                    .transition(.opacity)
                } else {
                    ContentView()
                        .transition(.opacity)
                }
            }
        }
    }
}
