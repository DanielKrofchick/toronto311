//
//  API.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-28.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import Foundation

class API {
    typealias Response = (Data?, URLResponse?, Error?) -> Void
    
    static func getServiceList(_ response: @escaping Response) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "secure.toronto.ca"
        components.path = "/webwizard/ws/services.json"
        components.queryItems = [
            jurisdiction(),
        ]
        
        if let url = components.url {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request, completionHandler: response).resume()
        }
    }
    
    static func getServiceRequests(_ response: @escaping Response) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "secure.toronto.ca"
        components.path = "/webwizard/ws/requests.json"
        components.queryItems = [
//            startDate(),
//            endDate(),
//            status(),
            jurisdiction(),
        ]
        
        if let url = components.url {
            let request = URLRequest(url: url)
            URLSession.shared.dataTask(with: request, completionHandler: response).resume()
        }
    }
    
    private static func startDate() -> URLQueryItem {
        return URLQueryItem(name: "start_date", value: "2015-02-01T00:00:00Z")
    }
    
    private static func endDate() -> URLQueryItem {
        return URLQueryItem(name: "end_date", value: "2015-02-07T00:00:00Z")
    }
    
    private static func jurisdiction() -> URLQueryItem {
        return URLQueryItem(name: "jurisdiction_id", value: "toronto.ca")
    }
    
    private static func status() -> URLQueryItem {
        return URLQueryItem(name: "status", value: "closed")
    }
}
