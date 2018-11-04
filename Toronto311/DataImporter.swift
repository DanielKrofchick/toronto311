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
    static func procesGeo(_ forEach: @escaping (Geometry) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let data = DataImporter.importJSON("WARD_WGS84")
            self.processGeo(data, forEach: forEach)
        }
    }
    
    static private func processGeo(_ data: Data, forEach: @escaping (Geometry) -> ()) {
        do {
            if let json = try Features.fromGeoJSON(data) {
                json.forEach { (feature) in
                    print(feature.id ?? "", feature.properties ?? "")
                    feature.geometries?.forEach({ (geometry) in
                        forEach(geometry)
                    })
                }
            }
        } catch {
            print(error)
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
