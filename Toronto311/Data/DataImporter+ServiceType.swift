//
//  DataImporter+ServiceType.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-12-26.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

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
        DispatchQueue.global(qos: .userInitiated).async {
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
