//
//  ServiceCodes.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-29.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

enum ServiceCodes: String {
    case CSROWBM03 = "CSROWBM-03"
    case CSROWC05 = "CSROWC-05"
    case CSROSC14 = "CSROSC-14"
    case CSROWR12 = "CSROWR-12"
    case C30102 = "30102"
    case SWLMALB02 = "SWLMALB-02"
    
    func color() -> UIColor {
        switch self {
        case .CSROWBM03: return .red
        case .CSROWC05: return .green
        case .CSROSC14: return .blue
        case .CSROWR12: return .orange
        case .C30102: return .magenta
        case .SWLMALB02: return .cyan
        }
    }
}

extension ServiceCodes: Codable {
}
