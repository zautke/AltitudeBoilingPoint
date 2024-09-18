//
//  SettingsView.swift
//  AltitudeBoilingPoint
//
//  Created by lucious lucius on 12/12/25.
//


//
//  SettingsView.swift
//  Boiling Point at Altitude
//
//  Settings sheet for unit preferences
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("useCelsius") private var useCelsius: Bool = false
    @AppStorage("useMeters") private var useMeters: Bool = false
    @AppStorage("useKPa") private var useKPa: Bool = false
    @AppStorage("accentColor") private var accentColorName: String = "jade"
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Use Celsius (°C)", isOn: $useCelsius)
                    Toggle("Use Meters (m)", isOn: $useMeters)
                    Toggle("Use Kilopascals (kPa)", isOn: $useKPa)
                } header: {
                    Text("Unit Preferences")
                } footer: {
                    Text("Toggle off to use Fahrenheit (°F), feet (ft), and inches of mercury (inHg)")
                }
                
                Section {
                    Picker("Accent Color", selection: $accentColorName) {
                        Text("Jade Green").tag("jade")
                        Text("Ocean Blue").tag("blue")
                        Text("Sunset Orange").tag("orange")
                        Text("Lavender Purple").tag("purple")
                        Text("Rose Pink").tag("rose")
                    }
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("Choose the accent color for icons and highlights")
                }
                
                Section {
                    HStack {
                        Text("Temperature Unit")
                        Spacer()
                        Text(useCelsius ? "°C" : "°F")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Altitude Unit")
                        Spacer()
                        Text(useMeters ? "meters" : "feet")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Pressure Unit")
                        Spacer()
                        Text(useKPa ? "kPa" : "inHg")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Current Settings")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick Tips:")
                            .font(.headline)
                        
                        Text("• Tap altitude and pressure values to toggle units temporarily")
                        Text("• Settings persist between app launches")
                        Text("• Changes apply immediately")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}