//
//  Ward.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-03.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import MapKit

struct Ward: Codable {
    var areaID: Int
    var areaName: String
    var areaLCD: String
    var areaSCD: String
    var areaType: String
    var latitude: Double
    var longitude: Double
    var x: Double
    var y: Double
    
    enum CodingKeys: String, CodingKey {
        case areaID = "AREA_ID"
        case areaName = "AREA_NAME"
        case areaLCD = "AREA_L_CD"
        case areaSCD = "AREA_S_CD"
        case areaType = "AREA_TYPE"
        case latitude = "LATITUDE"
        case longitude = "LONGITUDE"
        case x = "X"
        case y = "Y"
    }
}

class WardPolygon: MKPolygon {
    var ward: Ward?
}

extension MKPolygon {
    func toWardPolygon(_ ward: Ward) -> WardPolygon {
        let result = WardPolygon(points: points(), count: pointCount, interiorPolygons: interiorPolygons)
        result.ward = ward
        return result
    }
}

extension MKPolyline {
    func toWardPolygon(_ ward: Ward) -> WardPolygon {
        return toPolygon().toWardPolygon(ward)
    }
}
