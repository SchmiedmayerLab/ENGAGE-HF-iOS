//
// This source file is part of the ENGAGE-HF iOS open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


struct Medications: View {
    @Binding var presentingAccount: Bool
    
    @Environment(MedicationsManager.self) private var medicationsManager
    
    
    var body: some View {
        NavigationStack {
            MedicationsList(medications: medicationsManager.medications)
                .navigationTitle("Medications")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
#if DEBUG
                .toolbar {
                    if FeatureFlags.setupTestMedications {
                        ToolbarItem(placement: .secondaryAction) {
                            Button(action: { medicationsManager.injectTestMedications() }) {
                                Label { Text(verbatim: "Add Medications") } icon: { Image(systemName: "heart.text.square") }
                            }
                        }
                    }
                }
#endif
        }
    }
}


#Preview {
    Medications(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            MedicationsManager()
        }
}
