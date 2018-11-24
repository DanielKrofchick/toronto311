//
//  WardPolygon.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-14.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import MapKit

protocol WardOverlay: class {
    var isSelected: Bool {get set}
    var ward: Ward? {get set}
}

extension MKOverlay {
    func toggle(map: MKMapView) {
        if let self = self as? WardOverlay {
            self.isSelected.toggle()
        }
        map.removeOverlay(self)
        map.addOverlay(self)
    }
}

class WardPolygon: MKPolygon, WardOverlay {
    var ward: Ward?
    var isSelected = false
}

extension WardPolygon {
    func overlayRenderer() -> MKOverlayRenderer {
        let r = MKPolygonRenderer(polygon: self)
        
        r.lineWidth = 1.5
        
        if let source = ward?.wardSource {
            switch source {
            case .icitw_wgs84:
                r.strokeColor = .red
                r.fillColor = isSelected ? UIColor.red.withAlphaComponent(0.2) : UIColor.clear
            case .WARD_WGS84:
                r.strokeColor = .brown
                r.fillColor = isSelected ? UIColor.brown.withAlphaComponent(0.2) : UIColor.clear
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
