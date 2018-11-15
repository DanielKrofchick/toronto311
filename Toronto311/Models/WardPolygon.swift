//
//  WardPolygon.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-14.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import MapKit

class WardPolygon: MKPolygon {
    var ward: Ward?
    var isSelected = false
}

extension WardPolygon {
    func overlayRenderer() -> MKOverlayRenderer {
        let r = MKPolygonRenderer(polygon: self)
        
        r.strokeColor = .green
        r.lineWidth = 1.5
        r.fillColor = UIColor.clear
        
        if let source = ward?.wardSource {
            switch source {
            case .icitw_wgs84:
                r.fillColor = isSelected ? UIColor.red.withAlphaComponent(0.2) : UIColor.clear
            case .WARD_WGS84:
                r.fillColor = isSelected ? UIColor.blue.withAlphaComponent(0.2) : UIColor.clear
            }
        }
        
        return r
    }
}

extension MKPolygon {
    func wardPolygon(_ ward: Ward) -> WardPolygon {
        let result = WardPolygon(points: points(), count: pointCount, interiorPolygons: interiorPolygons)
        result.ward = ward
        return result
    }
}
