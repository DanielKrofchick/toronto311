//
//  Collection.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-11.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
