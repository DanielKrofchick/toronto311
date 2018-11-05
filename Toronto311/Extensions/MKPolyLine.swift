//
//  MKPolyLine.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-03.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import MapKit

extension MKPolyline {
    func polygon() -> MKPolygon {
        return MKPolygon(points: points(), count: pointCount)
    }
}
