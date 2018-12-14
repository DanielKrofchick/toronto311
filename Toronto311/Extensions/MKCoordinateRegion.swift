//
//  MKCoordinateRegion.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-12-13.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {
    static let toronto: MKCoordinateRegion = {
        let radius: CLLocationDistance = 20000
        let location = CLLocation.toronto + CLLocation(latitude: 0.08, longitude: 0)
        return MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
    }()
}
