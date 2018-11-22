//
//  CLLocation.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-31.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import MapKit

extension CLLocation {
    static let toronto = CLLocation(latitude: 43.6532, longitude: -79.3832)
    
    static func + (lhs: CLLocation, rhs: CLLocation) -> CLLocation {
        return CLLocation(latitude: lhs.coordinate.latitude + rhs.coordinate.latitude, longitude: lhs.coordinate.longitude + rhs.coordinate.longitude)
    }
}
