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

enum WardSource: String, CaseIterable {
    case WARD_WGS84
    case icitw_wgs84
    
    func name() -> String {
        switch self {
        case .WARD_WGS84:
            return "WARD"
        case .icitw_wgs84:
            return "icitw"
        }
    }
}

class Ward: NSManagedObject, Codable {
    var areaID: Int32? {
        get {
            willAccessValue(forKey: #function)
            defer { didAccessValue(forKey: #function) }
            return primitiveValue(forKey: #function) as? Int32
        }
        set {
            willChangeValue(forKey: #function)
            defer { didChangeValue(forKey: #function) }
            guard let value = newValue else { setPrimitiveValue(nil, forKey: #function); return }
            setPrimitiveValue(value, forKey: #function)
        }
    }
    @NSManaged var areaName: String?
    @NSManaged var areaLCD: String?
    @NSManaged var areaSCD: String?
    @NSManaged var areaType: String?
    var latitude: Double? {
        get {
            willAccessValue(forKey: #function)
            defer { didAccessValue(forKey: #function) }
            return primitiveValue(forKey: #function) as? Double
        }
        set {
            willChangeValue(forKey: #function)
            defer { didChangeValue(forKey: #function) }
            guard let value = newValue else { setPrimitiveValue(nil, forKey: #function); return }
            setPrimitiveValue(value, forKey: #function)
        }
    }
    var longitude: Double? {
        get {
            willAccessValue(forKey: #function)
            defer { didAccessValue(forKey: #function) }
            return primitiveValue(forKey: #function) as? Double
        }
        set {
            willChangeValue(forKey: #function)
            defer { didChangeValue(forKey: #function) }
            guard let value = newValue else { setPrimitiveValue(nil, forKey: #function); return }
            setPrimitiveValue(value, forKey: #function)
        }
    }
    var x: Double? {
        get {
            willAccessValue(forKey: #function)
            defer { didAccessValue(forKey: #function) }
            return primitiveValue(forKey: #function) as? Double
        }
        set {
            willChangeValue(forKey: #function)
            defer { didChangeValue(forKey: #function) }
            guard let value = newValue else { setPrimitiveValue(nil, forKey: #function); return }
            setPrimitiveValue(value, forKey: #function)
        }
    }
    var y: Double? {
        get {
            willAccessValue(forKey: #function)
            defer { didAccessValue(forKey: #function) }
            return primitiveValue(forKey: #function) as? Double
        }
        set {
            willChangeValue(forKey: #function)
            defer { didChangeValue(forKey: #function) }
            guard let value = newValue else { setPrimitiveValue(nil, forKey: #function); return }
            setPrimitiveValue(value, forKey: #function)
        }
    }
    var createID: Int32? {
        get {
            willAccessValue(forKey: #function)
            defer { didAccessValue(forKey: #function) }
            return primitiveValue(forKey: #function) as? Int32
        }
        set {
            willChangeValue(forKey: #function)
            defer { didChangeValue(forKey: #function) }
            guard let value = newValue else { setPrimitiveValue(nil, forKey: #function); return }
            setPrimitiveValue(value, forKey: #function)
        }
    }
    var objID: Int32? {
        get {
            willAccessValue(forKey: #function)
            defer { didAccessValue(forKey: #function) }
            return primitiveValue(forKey: #function) as? Int32
        }
        set {
            willChangeValue(forKey: #function)
            defer { didChangeValue(forKey: #function) }
            guard let value = newValue else { setPrimitiveValue(nil, forKey: #function); return }
            setPrimitiveValue(value, forKey: #function)
        }
    }
    @NSManaged var geoJSON: Data?
    @NSManaged var source: String?
    
    var wardSource: WardSource {
        switch source {
        case WardSource.WARD_WGS84.rawValue:
            return WardSource.WARD_WGS84
        case WardSource.icitw_wgs84.rawValue:
            return WardSource.icitw_wgs84
        default:
            return WardSource.icitw_wgs84
        }
    }
    
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
        areaID = try values.decodeIfPresent(Int32.self, forKey: .areaID)
        areaName = try values.decodeIfPresent(String.self, forKey: .areaName)
        areaLCD = try values.decodeIfPresent(String.self, forKey: .areaLCD)
        areaSCD = try values.decodeIfPresent(String.self, forKey: .areaSCD)
        areaType = try values.decodeIfPresent(String.self, forKey: .areaType)
        latitude = try values.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try values.decodeIfPresent(Double.self, forKey: .longitude)
        x = try values.decodeIfPresent(Double.self, forKey: .x)
        y = try values.decodeIfPresent(Double.self, forKey: .y)
        geoJSON = try values.decodeIfPresent(Data.self, forKey: .geoJSON)
        source = try values.decode(String.self, forKey: .source)
        createID = try values.decodeIfPresent(Int32.self, forKey: .createID)
        objID = try values.decodeIfPresent(Int32.self, forKey: .objID)
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
                  areaID: \(areaID == nil ? "nil" : String(describing: areaID!)),
                  areaName: \(areaName ?? "")
                  areaLCD: \(areaLCD ?? "")
                  areaSCD: \(areaSCD ?? "")
                  areaType: \(areaType ?? "")
                  latitude: \(latitude == nil ? "nil" : String(describing: latitude!)),
                  longitude: \(longitude == nil ? "nil" : String(describing: longitude!)),
                  x: \(x == nil ? "nil" : String(describing: x!)),
                  y: \(y == nil ? "nil" : String(describing: y!)),
                  createID: \(createID == nil ? "nil" : String(describing: createID!)),
                  objID: \(objID == nil ? "nil" : String(describing: objID!)),
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
            result[Ward.CodingKeys.areaID.rawValue] = self["GEO_ID"] as? Int32
            result[Ward.CodingKeys.areaName.rawValue] = self["NAME"] as? String
            result[Ward.CodingKeys.areaLCD.rawValue] = self["LCODE_NAME"] as? String
            result[Ward.CodingKeys.areaSCD.rawValue] = self["SCODE_NAME"] as? String
            result[Ward.CodingKeys.areaType.rawValue] = self["TYPE_DESC"] as? String
            result[Ward.CodingKeys.createID.rawValue] = self[Ward.CodingKeys.createID.rawValue] as? Int32
            result[Ward.CodingKeys.objID.rawValue] = self[Ward.CodingKeys.objID.rawValue] as? Int32
        case .WARD_WGS84:
            break
        }
        
        return result
    }
}

extension Ward: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
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
        
        DataController.shared.context.performAndWait {
            do {
                if let fetched = try DataController.shared.context.fetch(request) as? [Ward] {
                    result.append(contentsOf: fetched)
                }
            } catch {
                fatalError("failed to fetch wards: \(error)")
            }
        }
        
        return result
    }
}
