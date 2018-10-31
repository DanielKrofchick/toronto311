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
}
