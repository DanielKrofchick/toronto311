//
//  Ward.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-03.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class Ward: NSObject, Codable {
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
    var isSelected = false
}

class WardPolyline: MKPolyline {
    var ward: Ward?
    var isSelected = false
}

extension MKPolygon {
    func wardPolygon(_ ward: Ward) -> WardPolygon {
        let result = WardPolygon(points: points(), count: pointCount, interiorPolygons: interiorPolygons)
        result.ward = ward
        return result
    }
}

extension MKPolyline {
    func wardPolyline(_ ward: Ward) -> WardPolyline {
        let result = WardPolyline(points: points(), count: pointCount)
        result.ward = ward
        return result
    }
}

extension Ward {
    override var description: String {
        return
          """
          Ward(
            areaID: \(areaID),
            areaName: \(areaName)
            areaLCD: \(areaLCD)
            areaSCD: \(areaSCD)
            areaType: \(areaType)
            latitude: \(latitude)
            longitude: \(longitude)
            x: \(x)
            y: \(y)
          )
          """
    }
}

extension Ward: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    public var title: String? {
        return areaName
    }
    
    public var subtitle: String? {
        return String(describing: areaID)
    }
}
