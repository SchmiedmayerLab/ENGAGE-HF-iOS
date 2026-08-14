//
// This source file is part of the ENGAGE-HF iOS open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


extension HKObject {
    var externalID: String? {
        metadata?[HKMetadataKeyExternalUUID] as? String
    }
}
