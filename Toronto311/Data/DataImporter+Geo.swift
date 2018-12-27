//
//  DataImporter+Geo.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-12-26.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import GEOSwift

extension DataImporter {
    static func processGeos(completion: @escaping () -> ()) {
        let queue = DispatchQueue(label: "processGeos", attributes: .concurrent, target: .main)
        let group = DispatchGroup()
        
        group.enter()
        queue.async (group: group) {
            DataImporter.processGeo(source: .WARD_WGS84, completion: {
                group.leave()
            })
        }
        
        group.enter()
        queue.async (group: group) {
            DataImporter.processGeo(source: .icitw_wgs84, completion: {
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
    static func processGeo(source: WardSource, forEach: ((Ward)->())? = nil, completion: (()->())? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
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
                        DataController.shared.context.performAndWait({
                            if
                                let w: Ward? = properties.decodeDecodable(userInfo: [.context: DataController.shared.context]),
                                let ward = w
                            {
                                ward.geoJSON = try? JSONSerialization.data(withJSONObject: featureDictionary, options: [])
                                forEach?(ward)
                            }
                        })
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
