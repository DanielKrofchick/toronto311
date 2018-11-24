//
//  WardPolyline.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-14.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import MapKit

class WardPolyline: MKPolyline, WardOverlay {
    var ward: Ward?
    var isSelected = false
}

extension WardPolyline {
    func overlayRenderer() -> MKOverlayRenderer {
        let r = MKPolylineRenderer(polyline: self)
        
        r.lineWidth = 1.5

        if let source = ward?.wardSource {
            switch source {
            case .icitw_wgs84:
                r.strokeColor = isSelected ? .red : .blue
            case .WARD_WGS84:
                r.strokeColor = isSelected ? .brown : .green
            }
        }
        
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
