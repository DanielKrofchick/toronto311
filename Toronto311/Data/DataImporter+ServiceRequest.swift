//
//  DataImporter+ServiceRequest.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-12-26.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

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
        DispatchQueue.global(qos: .userInitiated).async {
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
