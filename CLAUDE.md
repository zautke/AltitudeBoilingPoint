# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

This is a SwiftUI iOS/macOS/visionOS app built with Xcode. The project uses `.xcodeproj` (no workspace or SPM dependencies).

```bash
# Build for simulator
xcodebuild -project AltitudeBoilingPoint.xcodeproj -scheme AltitudeBoilingPoint -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build for device
xcodebuild -project AltitudeBoilingPoint.xcodeproj -scheme AltitudeBoilingPoint -destination 'generic/platform=iOS' build

# Clean build
xcodebuild -project AltitudeBoilingPoint.xcodeproj -scheme AltitudeBoilingPoint clean
```

## Architecture

**AltitudeBoilingPoint** is a single-screen iOS app that calculates water's boiling point based on current altitude/atmospheric pressure.

### Core Components

- **AltitudeManager** (`AltitudeManager.swift`) - `@Observable` class that handles all sensor data:
  - Uses `CMAltimeter` for barometric pressure readings
  - Uses `CLLocationManager` for GPS-based altitude baseline
  - Calculates boiling point using the empirical formula: `BP(°F) = 49.161 × ln(P_inHg) + 44.932`
  - Marked `@MainActor` with `nonisolated` delegate methods that dispatch back to main actor

- **ContentView** (`ContentView.swift`) - Main UI with:
  - Temperature toggle (°F/°C)
  - Large boiling point display
  - Bottom info bar showing altitude and pressure (tappable to toggle units)
  - Custom gradient background component (`JadeGradientBackground`)

- **SettingsView** (`SettingsView.swift`) - Settings sheet for unit preferences and accent color

### State Management

User preferences are stored via `@AppStorage`:
- `useCelsius` - Temperature unit
- `useMeters` - Altitude unit
- `useKPa` - Pressure unit
- `accentColor` - Theme accent color name

### Required Permissions

Info.plist includes usage descriptions for:
- `NSLocationWhenInUseUsageDescription` - GPS altitude
- `NSMotionUsageDescription` - Barometric sensor

### Platform Support

Targets iOS 26.1+, macOS 26.1+, and visionOS 26.1+ (device families: iPhone, iPad, Vision Pro).
