//
//  FireStation.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-29.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

class FireStation: NSObject {
    let identifier: String
    let coordinate: CLLocationCoordinate2D
    
    init(identifier: String, coordinate: CLLocationCoordinate2D) {
        self.identifier = identifier
        self.coordinate = coordinate
        super.init()
    }
}

extension FireStation {
    static func importCSV() -> [FireStation] {
        return DataImporter.importCSV("FireStationsXY") { (input) -> FireStation? in
            var result: FireStation?
            
            if
                let x = Double(input[1]),
                let y = Double(input[2])
            {
                let coordinate = MKMapPoint(x: x, y: y).coordinate
                result = FireStation(identifier: input[0], coordinate: coordinate)
            }
            
            return result
        }
    }
}

extension FireStation {
    override var description: String {
        return "FireStation(\(identifier), \(coordinate)"
    }
}

import MapKit

extension FireStation: MKAnnotation {
    public var title: String? {
        return identifier
    }
    
    public var subtitle: String? {
        return "sub"
    }
}
