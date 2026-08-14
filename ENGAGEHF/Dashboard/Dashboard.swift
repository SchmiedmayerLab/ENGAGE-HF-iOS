//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
@_spi(TestingSupport) import SpeziAccount
@_spi(TestingSupport) import SpeziDevices
import SwiftUI


struct Dashboard: View {
    @Binding var presentingAccount: Bool
    
#if DEBUG
    @Environment(HealthMeasurements.self) private var measurements
#endif

    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    // Messages
                    MessagesSection()
                    
                    // Most recent vitals
                    RecentVitalsSection()
                }
                    .padding()
            }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Home")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
#if DEBUG
                .toolbar {
                    mockMeasurementActions
                }
#endif
        }
    }

#if DEBUG
    // Labelled verbatim: these drive the mock devices during development and are never shown to a participant.
    @ToolbarContentBuilder private var mockMeasurementActions: some ToolbarContent {
        if FeatureFlags.testMockDevices {
            ToolbarItemGroup(placement: .secondaryAction) {
                Button(action: { measurements.loadMockWeightMeasurement() }) {
                    Label { Text(verbatim: "Trigger Weight Measurement") } icon: { Image(systemName: "scalemass.fill") }
                }
                Button(action: { measurements.loadMockBloodPressureMeasurement() }) {
                    Label { Text(verbatim: "Trigger Blood Pressure Measurement") } icon: { Image(systemName: "drop.fill") }
                }
                Button(action: { measurements.shouldPresentMeasurements = true }) {
                    Label { Text(verbatim: "Show Measurements") } icon: { Image(systemName: "heart.text.square") }
                }
            }
        }
    }
#endif
}


#if DEBUG
#Preview {
    Dashboard(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            AccountConfiguration(service: InMemoryAccountService())
            MessageManager()
            HealthMeasurements(mock: [.weight(.mockWeighSample)])
            VitalsManager()
        }
}
#endif
