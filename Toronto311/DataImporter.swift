//
//  DataImporter.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-29.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

struct DataImporter {
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
