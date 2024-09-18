//
//  AltitudeManager.swift
//  AltitudeBoilingPoint
//
//  Created by lucious lucius on 12/12/25.
//


//
//  AltitudeManager.swift
//  Boiling Point at Altitude
//
//  COMPLETE WORKING FILE - Paste into Xcode
//

import Foundation
import CoreMotion
import CoreLocation
import Observation

@Observable
@MainActor
final class AltitudeManager: NSObject {
    // MARK: - Published State
    var currentAltitudeMeters: Double?
    var currentPressureKPa: Double?
    var boilingPointCelsius: Double?
    var errorMessage: String?
    var isUpdating: Bool = false
    
    // MARK: - Private Properties
    private let altimeter = CMAltimeter()
    private let locationManager = CLLocationManager()
    private var baselineAltitude: Double?
    
    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Public Methods
    func startMonitoring() {
        errorMessage = nil
        
        // Check location authorization
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if authStatus == .denied || authStatus == .restricted {
            errorMessage = "Location access denied. Enable in Settings to measure altitude."
            return
        }
        
        // Check altimeter availability
        guard CMAltimeter.isRelativeAltitudeAvailable() else {
            errorMessage = "Altimeter not available on this device."
            return
        }
        
        isUpdating = true
        
        // Start location updates for GPS altitude
        locationManager.startUpdatingLocation()
        
        // Start altimeter updates for pressure and relative changes
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Sensor error: \(error.localizedDescription)"
                self.isUpdating = false
                return
            }
            
            guard let data = data else { return }
            
            // Store pressure (convert from kPa to kPa - it's already in kPa)
            self.currentPressureKPa = data.pressure.doubleValue
            
            // If we have a baseline from GPS, add relative altitude
            if let baseline = self.baselineAltitude {
                self.currentAltitudeMeters = baseline + data.relativeAltitude.doubleValue
            }
            
            // Calculate boiling point from pressure
            self.calculateBoilingPoint()
        }
    }
    
    func stopMonitoring() {
        altimeter.stopRelativeAltitudeUpdates()
        locationManager.stopUpdatingLocation()
        isUpdating = false
    }
    
    // MARK: - Private Methods
    private func calculateBoilingPoint() {
        guard let pressureKPa = currentPressureKPa else { return }
        
        // Convert kPa to inHg (1 kPa = 0.2953 inHg)
        let pressureInHg = pressureKPa * 0.2953
        
        // Calculate boiling point using empirical formula
        // BP(°F) = 49.161 × ln(P) + 44.932
        let boilingPointF = 49.161 * log(pressureInHg) + 44.932
        
        // Convert to Celsius
        boilingPointCelsius = (boilingPointF - 32.0) * 5.0 / 9.0
    }
    
    // Alternative: Calculate from altitude directly
    private func calculateBoilingPointFromAltitude() {
        guard let altitudeMeters = currentAltitudeMeters else { return }
        
        // Convert to feet
        let altitudeFeet = altitudeMeters * 3.28084
        
        // Calculate pressure from altitude
        // P = 29.921 × (1 - 0.0000068753 × h)^5.2559
        let pressureInHg = 29.921 * pow(1.0 - 0.0000068753 * altitudeFeet, 5.2559)
        
        // Calculate boiling point
        let boilingPointF = 49.161 * log(pressureInHg) + 44.932
        
        // Convert to Celsius
        boilingPointCelsius = (boilingPointF - 32.0) * 5.0 / 9.0
    }
}

// MARK: - CLLocationManagerDelegate
extension AltitudeManager: CLLocationManagerDelegate {
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            // Set baseline altitude from GPS
            if self.baselineAltitude == nil {
                self.baselineAltitude = location.altitude
                self.currentAltitudeMeters = location.altitude
            }
            
            // If we don't have pressure yet, calculate boiling point from altitude
            if self.currentPressureKPa == nil {
                self.calculateBoilingPointFromAltitude()
            }
        }
    }
    
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        Task { @MainActor in
            self.errorMessage = "Location error: \(error.localizedDescription)"
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        Task { @MainActor in
            let status = manager.authorizationStatus
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.startMonitoring()
            } else if status == .denied || status == .restricted {
                self.errorMessage = "Location access denied. Enable in Settings."
                self.isUpdating = false
            }
        }
    }
}