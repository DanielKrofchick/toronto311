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

enum WardSource: String {
    case WARD_WGS84
    case icitw_wgs84
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
        case createID = "CREATE_ID"
        case objID = "OBJECTID"
        case geoJSON
        case source
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard
            let context = decoder.userInfo[.context] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: NSEntityDescriptionName.ward, in: context)
            else {fatalError("Failed to decode \(NSEntityDescriptionName.ward)")}
        
        self.init(entity: entity, insertInto: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        areaID = try values.decodeIfPresent(Int32.self, forKey: .areaID) ?? Int32.max
        areaName = try values.decodeIfPresent(String.self, forKey: .areaName)
        areaLCD = try values.decodeIfPresent(String.self, forKey: .areaLCD)
        areaSCD = try values.decodeIfPresent(String.self, forKey: .areaSCD)
        areaType = try values.decodeIfPresent(String.self, forKey: .areaType)
        latitude = try values.decodeIfPresent(Double.self, forKey: .latitude) ?? Double.greatestFiniteMagnitude
        longitude = try values.decodeIfPresent(Double.self, forKey: .longitude) ?? Double.greatestFiniteMagnitude
        x = try values.decodeIfPresent(Double.self, forKey: .x) ?? Double.greatestFiniteMagnitude
        y = try values.decodeIfPresent(Double.self, forKey: .y) ?? Double.greatestFiniteMagnitude
        geoJSON = try values.decodeIfPresent(Data.self, forKey: .geoJSON)
        source = try values.decode(String.self, forKey: .source)
        createID = try values.decodeIfPresent(Int32.self, forKey: .createID) ?? Int32.max
        objID = try values.decodeIfPresent(Int32.self, forKey: .objID) ?? Int32.max
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
        try container.encode(source, forKey: .source)
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

extension Dictionary where Key == String, Value == Any {
    func transform(for source: WardSource) -> [String: Any] {
        var result = self

        result[Ward.CodingKeys.source.rawValue] = source.rawValue
        
        switch source {
        case .icitw_wgs84:
            result[Ward.CodingKeys.areaID.rawValue] = self["GEO_ID"] as? Int32 ?? Int32.max
            result[Ward.CodingKeys.areaName.rawValue] = self["NAME"] as? String ?? ""
            result[Ward.CodingKeys.areaLCD.rawValue] = self["LCODE_NAME"] as? String ?? ""
            result[Ward.CodingKeys.areaSCD.rawValue] = self["SCODE_NAME"] as? String ?? ""
            result[Ward.CodingKeys.areaType.rawValue] = self["TYPE_DESC"] as? String ?? ""
            result[Ward.CodingKeys.createID.rawValue] = self[Ward.CodingKeys.createID.rawValue] as? Int32 ?? Int32.max
            result[Ward.CodingKeys.objID.rawValue] = self[Ward.CodingKeys.objID.rawValue] as? Int32 ?? Int32.max
        case .WARD_WGS84:
            break
        }
        
        return result
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
