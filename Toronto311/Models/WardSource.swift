//
//  WardSource.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-22.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

enum WardSource: String, CaseIterable {
    case WARD_WGS84
    case icitw_wgs84
    
    func name() -> String {
        switch self {
        case .WARD_WGS84:
            return "WARD"
        case .icitw_wgs84:
            return "icitw"
        }
    }
}

extension WardSource: Comparable {
    static func < (lhs: WardSource, rhs: WardSource) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
