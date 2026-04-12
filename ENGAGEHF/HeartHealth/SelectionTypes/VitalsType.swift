//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// The type of health data to be displayed as the main content of Heart Health view, after selecting .bloodPressure, .weight, or .heartRate
enum VitalsType: CustomStringConvertible {
    case weight
    case heartRate
    case bloodPressure
    
    
    var description: String {
        switch self {
        case .weight: String(localized: "Body Weight", comment: "Vitals type label")
        case .heartRate: String(localized: "Heart Rate", comment: "Vitals type label")
        case .bloodPressure: String(localized: "Blood Pressure", comment: "Vitals type label")
        }
    }
    
    /// The localized description of the vitals type
    var localizedExplanation: String {
        switch self {
        case .weight: String(localized: "vitalsWeight")
        case .heartRate: String(localized: "vitalsHeartRate")
        case .bloodPressure: String(localized: "vitalsBloodPressure")
        }
    }
    
    /// The corresponding GraphSelection associted with each VitalsType
    var graphType: GraphSelection {
        switch self {
        case .weight: .weight
        case .heartRate: .heartRate
        case .bloodPressure: .bloodPressure
        }
    }
    
    /// The HKUnit corresponding to each vitals type
    var unit: VitalsUnit {
        switch self {
        case .weight: Locale.current.measurementSystem == .us ? .lbs : .kgs
        case .heartRate: .bpm
        case .bloodPressure: .mmHg
        }
    }
}
