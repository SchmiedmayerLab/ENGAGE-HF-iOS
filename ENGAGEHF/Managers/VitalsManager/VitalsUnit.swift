//
// This source file is part of the ENGAGE-HF iOS open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


enum VitalsUnit: CustomStringConvertible {
    case mmHg
    case lbs
    case kgs
    case bpm
    
    
    var description: String {
        switch self {
        case .lbs: String(localized: "lb", comment: "Unit abbreviation for pounds")
        case .kgs: String(localized: "kg", comment: "Unit abbreviation for kilograms")
        case .mmHg: String(localized: "mmHg", comment: "Unit abbreviation for millimeters of mercury")
        case .bpm: String(localized: "BPM", comment: "Unit abbreviation for beats per minute")
        }
    }
    
    var hkUnit: HKUnit {
        switch self {
        case .lbs: .pound()
        case .kgs: .gramUnit(with: .kilo)
        case .mmHg: .millimeterOfMercury()
        case .bpm: .count().unitDivided(by: .minute())
        }
    }
}
