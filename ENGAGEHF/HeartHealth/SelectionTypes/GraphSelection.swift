//
// This source file is part of the ENGAGE-HF iOS open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation
import HealthKit


/// The type of Vitals to be displayed as the main content of the Heart Health view
/// Chosen by GraphPicker in HeartHealth
enum GraphSelection: CaseIterable, Identifiable, CustomStringConvertible, Equatable {
    case symptoms
    case weight
    case heartRate
    case bloodPressure
    
    
    var id: Self {
        self
    }
    
    var description: String {
        switch self {
        case .symptoms: String(localized: "Symptoms", comment: "Graph selection short label")
        case .weight: String(localized: "Weight", comment: "Graph selection short label")
        case .heartRate: String(localized: "HR", comment: "Graph selection short label for Heart Rate")
        case .bloodPressure: String(localized: "BP", comment: "Graph selection short label for Blood Pressure")
        }
    }

    var fullName: String {
        switch self {
        case .symptoms: String(localized: "Symptom Score", comment: "Graph selection full name")
        case .weight: String(localized: "Body Weight", comment: "Graph selection full name")
        case .heartRate: String(localized: "Heart Rate", comment: "Graph selection full name")
        case .bloodPressure: String(localized: "Blood Pressure", comment: "Graph selection full name")
        }
    }
    
    var localizedEmptyHistoryWarning: String {
        switch self {
        case .symptoms: String(localized: "symptomsMissing")
        case .weight: String(localized: "weightMissing")
        case .heartRate: String(localized: "heartRateMissing")
        case .bloodPressure: String(localized: "bloodPressureMissing")
        }
    }
    

    func collectionReference(for accountId: String) -> CollectionReference? {
        switch self {
        case .symptoms:
            Firestore.symptomScoresCollectionReference(for: accountId)
        case .weight:
            Firestore.collectionReference(for: accountId, type: HKQuantityType(.bodyMass))
        case .heartRate:
            Firestore.collectionReference(for: accountId, type: HKQuantityType(.heartRate))
        case .bloodPressure:
            Firestore.collectionReference(for: accountId, type: HKCorrelationType(.bloodPressure))
        }
    }
}
