//
//  DataImporter.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-29.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import GEOSwift

struct DataImporter {
    enum Source {
        case disk
        case api
    }
    
    static func importCSV<T>(_ name: String, transform: ([String]) -> T?) -> [T] {
        guard let asset = NSDataAsset(name: name) else {
            fatalError("missing data asset: \(name)")
        }
        
        var result = [T]()
        
        if let string = String(data: asset.data, encoding: String.Encoding.utf8) {
            string.components(separatedBy: "\r\n").forEach { (s) in
                let components = s.components(separatedBy: ",")
                if let transformed = transform(components) {
                    result.append(transformed)
                }
            }
        }
        
        return result
    }
    
    static func importJSON(_ name: String) -> Data {
        guard let asset = NSDataAsset(name: name) else {
            fatalError("missing data asset: \(name)")
        }
        
        return asset.data
    }
}

extension DataImporter {
    static func procesGeo(forEach: ((Ward)->())? = nil, completion: (()->())? = nil) {
        DispatchQueue.global(qos: .background).async {
//            let source = WardSource.WARD_WGS84
            let source = WardSource.icitw_wgs84
            let data = DataImporter.importJSON(source.rawValue)
            self.processGeo(data, source: source, forEach: forEach, completion: completion)
        }
    }
    
    static private func processGeo(_ data: Data, source: WardSource, forEach: ((Ward)->())? = nil, completion: (()->())? = nil) {
        do {
            if
                let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let type = dictionary["type"] as? String,
                type == "FeatureCollection",
                let features = dictionary["features"] as? [[String: Any]]
            {
                features.forEach { (featureDictionary) in
                    if var properties = featureDictionary["properties"] as? [String: Any] {
                        properties = properties.transform(for: source)

                        print(properties.json() ?? "")
                        
                        if
                            let w: Ward? = properties.decodeDecodable(userInfo: [.context: DataController.shared.context]),
                            let ward = w
                        {
                            ward.geoJSON = try? JSONSerialization.data(withJSONObject: featureDictionary, options: [])
                            DataController.shared.save()
                            forEach?(ward)
                        }
                    }
                }
                completion?()
            }
        } catch {
            print(error)
            completion?()
        }
    }
}

extension DataImporter {
    static func processServiceRequests(_ source: Source, forEach: @escaping (ServiceRequest) -> ()) {
        switch source {
        case .disk:
            processServiceRequestsDisk(forEach)
        case .api:
            processServiceRequestsAPI(forEach)
        }
    }
    
    static func processServiceRequestsDisk(_ forEach: @escaping (ServiceRequest) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let data = DataImporter.importJSON("ServiceRequests")
            self.processServiceRequests(data, forEach: forEach)
        }
    }
    
    static func processServiceRequestsAPI(_ forEach: @escaping (ServiceRequest) -> ()) {
        API.getServiceRequests { (data, response, error) in
            if error != nil {
                print("error", (response as? HTTPURLResponse)?.statusCode ?? "")
            } else if let data = data {
                self.processServiceRequests(data, forEach: forEach)
            }
        }
    }
    
    static private func processServiceRequests(_ data: Data, forEach: @escaping (ServiceRequest) -> ()) {
        do {
            let requests = try JSONDecoder()
                .decode(ServiceRequestContainer.self, from: data)
                .service_requests
            DispatchQueue.main.async {
                requests.forEach {forEach($0)}
            }
        } catch {
            print(error)
        }
    }
}

extension DataImporter {
    static func processServiceList(_ source: Source, forEach: @escaping (ServiceType) -> ()) {
        switch source {
        case .disk:
            processServiceListDisk(forEach)
        case .api:
            processServiceListAPI(forEach)
        }
    }
    
    static func processServiceListDisk(_ forEach: @escaping (ServiceType) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let data = DataImporter.importJSON("ServiceList")
            self.processServiceList(data, forEach: forEach)
        }
    }
    
    static func processServiceListAPI(_ forEach: @escaping (ServiceType) -> ()) {
        API.getServiceList { (data, response, error) in
            if error != nil {
                print("error", (response as? HTTPURLResponse)?.statusCode ?? "")
            } else if let data = data {
                self.processServiceList(data, forEach: forEach)
            }
        }
    }
    
    static func processServiceList(_ data: Data, forEach: @escaping (ServiceType) -> ()) {
        do {
            let types = try JSONDecoder()
                .decode([ServiceType].self, from: data)
            DispatchQueue.main.async {
                types.forEach {forEach($0)}
            }
        } catch {
            print(error)
        }
    }
}

extension DataImporter {
    static func processFirestations(_ forEach: @escaping (FireStation) -> ()) {
        FireStation.importCSV().forEach {forEach($0)}
    }
}
