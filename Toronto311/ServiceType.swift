//
//  ServiceType.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-30.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import Foundation

class ServiceType: NSObject, Codable {
    var des: String?
    var service_code: ServiceCodes!
    var group: String?
    var type: String?
    var keywords: String?
    var service_name: String?
    var metadata: Bool?
    
    enum CodingKeys: String, CodingKey {
        case des = "description"
        case service_code
        case group
        case type
        case keywords
        case service_name
        case metadata
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        des = try container.decodeIfPresent(String.self, forKey: .des)
        group = try container.decodeIfPresent(String.self, forKey: .group)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        keywords = try container.decodeIfPresent(String.self, forKey: .keywords)
        service_name = try container.decodeIfPresent(String.self, forKey: .service_name)
        metadata = try container.decodeIfPresent(Bool.self, forKey: .metadata)
        
        if let code = try? container.decodeIfPresent(String.self, forKey: .service_code) {
            if
                let code = code,
                let c = ServiceCodes(rawValue: code)
            {
                service_code = c
            }
        } else if let code = try? container.decodeIfPresent(Int.self, forKey: .service_code) {
            if
                let code = code,
                let c = ServiceCodes(rawValue: String(describing: code))
            {
                service_code = c
            }
        }
    }
}

extension ServiceType {
    override var description: String {
        return "ServiceType(\(service_code!))"
    }
}
