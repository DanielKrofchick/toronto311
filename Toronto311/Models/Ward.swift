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
import GEOSwift

extension NSEntityDescriptionName {
    static var ward: String {return "Ward"}
}

class Ward: NSManagedObject, Codable {
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
        case geoJSON
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard
            let context = decoder.userInfo[.context] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: NSEntityDescriptionName.ward, in: context)
            else {fatalError("Failed to decode \(NSEntityDescriptionName.ward)")}
        
        self.init(entity: entity, insertInto: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        areaID = try values.decode(Int32.self, forKey: .areaID)
        areaName = try values.decode(String.self, forKey: .areaName)
        areaLCD = try values.decode(String.self, forKey: .areaLCD)
        areaSCD = try values.decode(String.self, forKey: .areaSCD)
        areaType = try values.decode(String.self, forKey: .areaType)
        latitude = try values.decode(Double.self, forKey: .latitude)
        longitude = try values.decode(Double.self, forKey: .longitude)
        x = try values.decode(Double.self, forKey: .x)
        y = try values.decode(Double.self, forKey: .y)
        geoJSON = try values.decodeIfPresent(Data.self, forKey: .geoJSON)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(areaID, forKey: .areaID)
        try container.encode(areaName, forKey: .areaName)
        try container.encode(areaLCD, forKey: .areaLCD)
        try container.encode(areaSCD, forKey: .areaSCD)
        try container.encode(areaType, forKey: .areaType)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encodeIfPresent(geoJSON, forKey: .geoJSON)

    }
}

extension Ward {
    override var description: String {
        return """
                Ward(
                  areaID: \(areaID),
                  areaName: \(areaName ?? "")
                  areaLCD: \(areaLCD ?? "")
                  areaSCD: \(areaSCD ?? "")
                  areaType: \(areaType ?? "")
                  latitude: \(latitude)
                  longitude: \(longitude)
                  x: \(x)
                  y: \(y)
                )
                """
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

extension Ward {
    func features() -> [Feature] {
        var result = [Feature]()
        
        if
            let geoJSON = geoJSON,
            let f = try? Features.fromGeoJSON(geoJSON),
            let features = f
        {
            result = features
        }
        
        return result
    }
}

extension Ward {
    static func all() -> [Ward] {
        var result = [Ward]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: NSEntityDescriptionName.ward)
        
        do {
            if let fetched = try DataController.shared.context.fetch(request) as? [Ward] {
                result.append(contentsOf: fetched)
            }
        } catch {
            fatalError("failed to fetch wards: \(error)")
        }
        
        return result
    }
}
