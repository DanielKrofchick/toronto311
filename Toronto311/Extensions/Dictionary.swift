//
//  Dictionary.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-28.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import Foundation

extension Dictionary {
    func json() -> String? {
        var result: String?
        
        if
            let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
            let string = String(data: data, encoding: String.Encoding.utf8)
        {
            result = string
        }
        
        return result
    }
    
    func decodeDecodable<T: Decodable>(userInfo: [CodingUserInfoKey: Any]? = nil) -> T? {
        var result: T?
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let string = String(data: jsonData, encoding: String.Encoding.utf8)
            if let data = string?.data(using: String.Encoding.utf8) {
                let decoder = JSONDecoder()
                userInfo?.forEach {
                    decoder.userInfo[$0.key] = $0.value
                }
                result = try decoder.decode(T.self, from: data)
            }
        } catch {
            print(error)
        }
        
        return result
    }
}
