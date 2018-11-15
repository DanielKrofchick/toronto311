//
//  WardPolyline.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-14.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import MapKit

class WardPolyline: MKPolyline {
    var ward: Ward?
    var isSelected = false
}

extension WardPolyline {
    func overlayRenderer() -> MKOverlayRenderer {
        let r = MKPolylineRenderer(polyline: self)
        
        r.strokeColor = .blue
        r.lineWidth = 1.5
        r.strokeColor = isSelected ? .red : .blue
        
        return r
    }
}

extension MKPolyline {
    func wardPolyline(_ ward: Ward) -> WardPolyline {
        let result = WardPolyline(points: points(), count: pointCount)
        result.ward = ward
        return result
    }
}
