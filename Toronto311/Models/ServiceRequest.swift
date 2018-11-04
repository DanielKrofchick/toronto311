//
//  ServiceRequest.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-29.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import Foundation
import MapKit

class ServiceRequest: NSObject, Codable {
    var des: String?
    var updated_datetime: String?
    var service_name: String?
    var long: Double?
    var service_request_id: Int
    var service_notice: String?
    var agency_responsible: String?
    var address_id: Int?
    var address: String?
    var status_notes: String?
    var expected_datetime: String?
    var zipcode: String?
    var lat: Double?
    var media_url: String?
    var requested_datetime: String?
    var status: String?
    var service_code: ServiceCodes?
    
    enum CodingKeys: String, CodingKey {
        case des = "description"
        case updated_datetime
        case service_name
        case long
        case service_request_id
        case service_notice
        case agency_responsible
        case address_id
        case address
        case status_notes
        case expected_datetime
        case zipcode
        case lat
        case media_url
        case requested_datetime
        case status
        case service_code
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        des = try container.decodeIfPresent(String.self, forKey: .des)
        updated_datetime = try container.decodeIfPresent(String.self, forKey: .updated_datetime)
        service_name = try container.decodeIfPresent(String.self, forKey: .service_name)
        long = try container.decodeIfPresent(Double.self, forKey: .long)
        service_request_id = try container.decode(Int.self, forKey: .service_request_id)
        service_notice = try container.decodeIfPresent(String.self, forKey: .service_notice)
        agency_responsible = try container.decodeIfPresent(String.self, forKey: .agency_responsible)
        address_id = try container.decodeIfPresent(Int.self, forKey: .address_id)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        status_notes = try container.decodeIfPresent(String.self, forKey: .status_notes)
        expected_datetime = try container.decodeIfPresent(String.self, forKey: .expected_datetime)
        zipcode = try container.decodeIfPresent(String.self, forKey: .zipcode)
        lat = try container.decodeIfPresent(Double.self, forKey: .lat)
        media_url = try container.decodeIfPresent(String.self, forKey: .media_url)
        requested_datetime = try container.decodeIfPresent(String.self, forKey: .requested_datetime)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        
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

extension ServiceRequest: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat ?? 0, longitude: long ?? 0)
    }
    public var title: String? {
        return String(describing: address ?? "")
    }
    
    public var subtitle: String? {
        return String(describing: service_request_id)
    }
}

class ServiceRequestContainer: Codable {
    let service_requests: [ServiceRequest]
}
