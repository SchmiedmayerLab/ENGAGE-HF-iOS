//
// This source file is part of the ENGAGE-HF iOS open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct FieldDetails: Identifiable {
    let id = UUID()
    
    var title: String
    var value: Double?
}
