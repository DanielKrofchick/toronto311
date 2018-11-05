//
//  MKPolygon.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-04.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import MapKit

extension MKPolygon {
    func polyline() -> MKPolyline {
        return MKPolyline(points: points(), count: pointCount)
    }
}
